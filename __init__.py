from adapt.intent import IntentBuilder
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from collections import defaultdict
from enum import Enum
from mycroft.messagebus.message import Message
from mycroft.skills.core import MycroftSkill, intent_handler
from mycroft.util.log import getLogger
from os.path import join, dirname, abspath
from pathlib import Path
from threading import Lock
from typing import Dict, List
from time import sleep, time
from uuid import uuid4 as uuid
import json
import re


__author__ = 'ChristopherRogers1991'

LOGGER = getLogger(__name__)
ROUTINES_FILENAME = "routines.json"
ROUTINES_V2_FILENAME = "routines2.json"

TIMEOUT_IN_SECONDS = 30


class _TaskStatus(Enum):
    RUNNING = 0
    FINISHED = 1


class _TaskTracker():

    def __init__(self, id):
        self._id = id
        self._status = _TaskStatus.RUNNING
        self._start_time = time()

    def __str__(self):
        return str(self.__dict__)

    def mark_finished(self):
        self._status = _TaskStatus.FINISHED

    def is_done(self):
        return self._status == _TaskStatus.FINISHED

    def is_stale(self):
        return self._start_time + TIMEOUT_IN_SECONDS + 1 < time()

class _Routine():

    def __init__(self,
                name: str,
                tasks: List[str],
                schedule: str=None,
                enabled: bool=True) -> None:
        self.name = name
        self.tasks = tasks
        self.schedule = schedule
        self.enabled = enabled

    @classmethod
    def from_json(cls, json_string: str):
        return cls(**json.loads(json_string))


class MycroftRoutineSkill(MycroftSkill):

    def __init__(self):
        super(MycroftRoutineSkill, self).__init__(name="MycroftRoutineSkill")
        self._in_progress_tasks = dict()
        self._in_progress_tasks_lock = Lock()
        self.gui_image_directory = Path(self.root_dir).joinpath("ui")

    def initialize(self):
        self.scheduler = BackgroundScheduler()
        self.scheduler.start()

        self._routines = self._load_routine_data()

        self._routine_to_sched_id_map = {}
        self._register_routines()

        path = dirname(abspath(__file__))

        path_to_stop_words = join(path, 'vocab', self.lang, 'ThatsAll.voc')
        self._stop_words = self._lines_from_path(path_to_stop_words)

        path_to_cancel_words = join(path, 'vocab', self.lang, 'Cancel.voc')
        self._cancel_words = self._lines_from_path(path_to_cancel_words)

        path_to_days_of_week = join(path, 'vocab', self.lang, 'DaysOfWeek.voc')
        self._days_of_week = self._lines_from_path(path_to_days_of_week)

        self.add_event("mycroft.skill.handler.complete",
                       self._handle_completed_event)
        self.gui.register_handler("skill.mycroft_routine_skill.run_routine_button_clicked",
                                  self._trigger_routine)
        self.gui.register_handler("skill.mycroft_routine_skill.edit_routine_button_clicked",
                                  self._edit_routine)
        self.gui.register_handler("skill.mycroft_routine_skill.edit_task_button_clicked",
                                  self._edit_task)
        self.gui.register_handler("skill.mycroft_routine_skill.add_task_button_clicked",
                                  self._add_task)

    def _handle_completed_event(self, message):
        task_id = message.context.get("task_id")
        with self._in_progress_tasks_lock:
            if task_id not in self._in_progress_tasks:
                return
            LOGGER.info(task_id + " completed.")
            self._in_progress_tasks[task_id].mark_finished()

    def _await_completion_of_task(self, task_id):
        LOGGER.info("Waiting for " + task_id)
        start = time()
        while start + TIMEOUT_IN_SECONDS > time():
            with self._in_progress_tasks_lock:
                try:
                    if self._in_progress_tasks[task_id].is_done():
                        del(self._in_progress_tasks[task_id])
                        return
                except KeyError:
                    sleep(0.1)
        LOGGER.warn("Timed out wating for {task}".format(task=task_id))
        del(self._in_progress_tasks[task_id])

    def send_message(self, message: str):
        task_id = "{name}.{uuid}".format(name=self.name, uuid=uuid())
        with self._in_progress_tasks_lock:
            self._in_progress_tasks[task_id] = _TaskTracker(task_id)
        self.bus.emit(Message(
            msg_type="recognizer_loop:utterance",
            data={"utterances": [message]},
            context={"task_id": task_id}
        ))
        return task_id

    def _lines_from_path(self, path):
        with open(path, 'r') as file:
            lines = [line.strip().lower() for line in file]
            return lines

    def _load_routine_data(self) -> Dict[str, _Routine]:
        try:
            with self.file_system.open(ROUTINES_V2_FILENAME, 'r') as conf_file:
                routines = json.loads(conf_file.read())
                routines = [_Routine(**routine) for routine in routines]
                return {routine.name: routine for routine in routines}
        except FileNotFoundError:
            try:
                with self.file_system.open(ROUTINES_FILENAME, 'r') as conf_file:
                    routines = json.loads(conf_file.read())
                    return {name: _Routine(name, **routine) for name, routine in routines.items()}
            except FileNotFoundError:
                log_message = "Routines file not found."
        except PermissionError:
            log_message = "Permission denied when reading routines file."
        except json.decoder.JSONDecodeError:
            log_message = "Error decoding json from routines file."
        log_message += " Initializing empty dict."
        LOGGER.warn(log_message)
        return {}

    def _register_routines(self):
        for routine in self._routines.values():
            self._register_routine(routine)

    def _register_routine(self, routine: _Routine):
        self.register_vocabulary(routine.name, "RoutineName")
        if routine.schedule and routine.enabled:
            self._schedule_routine(routine.name, routine.schedule)

    def _schedule_routine(self, name, cronstring):
        trigger = CronTrigger.from_crontab(cronstring)
        job = self.scheduler.add_job(func=self._run_routine,
                               args=[name], trigger=trigger, name=name)
        self._routine_to_sched_id_map[name] = job.id

    def _write_routine_data(self):
        with self.file_system.open(ROUTINES_V2_FILENAME, 'w') as conf_file:
            routines = [routine.__dict__ for routine in self._routines.values()]
            conf_file.write(json.dumps(routines, indent=4))

    @intent_handler(IntentBuilder("CreateRoutine").require("Create").require("Routine"))
    def _create_routine(self, message):
        name = self.get_response("name.it")
        if not name:
            return
        name = name.lower()
        if name in self._cancel_words:
            return

        tasks = self._get_task_list()
        if not tasks:
            return

        new_routine = _Routine(name, tasks)
        self._routines[name] = new_routine

        self._write_routine_data()
        self._register_routine(new_routine)
        self.speak_dialog('created', data={"name": name})

    def _get_task_list(self):
        first_task = self.get_response("first.task")
        if not first_task:
            return []
        first_task = first_task.lower()
        if first_task in self._cancel_words:
            return []
        tasks = [first_task]
        while True:
            task = self.get_response("next")
            if not task:
                return []
            task = task.lower()
            if task in self._cancel_words:
                return []
            if task in self._stop_words:
                break
            tasks.append(task)
        return tasks

    def _edit_routine(self, message):
        routine_name = message.data["RoutineName"].lower()
        self.gui.clear()
        self.gui["routineName"] = routine_name
        self.gui['tasks'] = json.dumps(self._routines[routine_name].tasks)
        self.gui.show_page("edit_routine.qml")

    def _edit_task(self, message):
        new_task = self.get_response()
        if not new_task:
            return
        routine_name = message.data["RoutineName"].lower()
        task_index = message.data["TaskIndex"]
        self._routines[routine_name].tasks[task_index] = new_task
        self.gui['tasks'] = json.dumps(self._routines[routine_name].tasks)
        self.gui.show_page("edit_routine.qml")
        self._write_routine_data()

    def _add_task(self, message):
        new_task = self.get_response()
        if not new_task:
            return
        routine_name = message.data["RoutineName"].lower()
        self._routines[routine_name].tasks.append(new_task)
        self.gui['tasks'] = json.dumps(self._routines[routine_name].tasks)
        self.gui.show_page("edit_routine.qml")
        self._write_routine_data()
        

    @intent_handler(IntentBuilder("RunRoutine").optionally("Run").require("RoutineName"))
    def _trigger_routine(self, message):
        name = message.data["RoutineName"]
        self._run_routine(name)

    def _run_routine(self, name):
        for task in self._routines[name.lower()].tasks:
            task_id = self.send_message(task)
            self._await_completion_of_task(task_id)

    @intent_handler(IntentBuilder("ListRoutine").require("List").require("Routines"))
    def _list_routines(self, message):
        if not self._routines:
            self.speak_dialog('no.routines')
            return
        routines = ". ".join(self._routines.keys())
        self.gui.clear()
        self.gui['routinesModel'] = json.dumps([routine.title() for routine in self._routines.keys()])
        self.gui.show_page("routine_list.qml")
        self.speak_dialog('list.routines')
        self.speak(routines)

    @intent_handler(IntentBuilder("DeleteRoutine").require("Delete").require("RoutineName"))
    def _delete_routine(self, message):
        name = message.data["RoutineName"]
        del(self._routines[name])
        self._write_routine_data()
        self.speak_dialog('deleted', data={"name": name})

    @intent_handler(IntentBuilder("DescribeRoutine").require("Describe").require("RoutineName"))
    def _describe_routine(self, message):
        name = message.data["RoutineName"]
        tasks = ". ".join(self._routines[name].tasks)
        self.speak_dialog('describe', data={"name": name})
        self.speak(tasks)

    @intent_handler(IntentBuilder("ScheduleRoutine").require("Schedule").require("RoutineName"))
    def _add_routine_schedule(self, message):
        name = message.data["RoutineName"]
        days = self._get_days()
        hour, minute = self._get_time()
        cronstring = self._generate_cronstring(days, hour, minute)
        self._routines[name].schedule = cronstring
        self._routines[name].enabled = True
        self._write_routine_data()
        self._schedule_routine(name, cronstring)
        self.speak_dialog("scheduled", data={'name': name})

    @intent_handler(IntentBuilder("DisableRoutine").require("Disable").require("RoutineName"))
    def _disable_scheduled_routine(self, message):
        name = message.data["RoutineName"]
        if not self._routines[name].enabled:
            return
        self._routines[name].enabled = False
        self._write_routine_data()
        self.scheduler.remove_job(self._routine_to_sched_id_map[name])
        self.speak_dialog("disabled", data={"name": name})

    @intent_handler(IntentBuilder("EnableRoutine").require("Enable").require("RoutineName"))
    def _enable_scheduled_routine(self, message):
        name = message.data["RoutineName"]
        self._routines[name].enabled = True
        self._write_routine_data()
        self._schedule_routine(name, self._routines[name].schedule)
        self.speak_dialog("enabled", data={"name": name})

    def _get_days(self):
        days_to_run = []
        days_from_user = self.get_response('which.days')
        if not days_from_user:
            return
        days_from_user = days_from_user.lower()
        for i in range(len(self._days_of_week)):
            if self._days_of_week[i] in days_from_user:
                days_to_run.append(str(i))
        return ','.join(days_to_run)

    def _get_time(self):
        regex = '(?P<hour>[0-9]{1,2})[: ](?P<minute>[0-9]{1,2}) (?P<time_of_day>[ap].?m.?)'
        time_from_user = self.get_response('what.time')
        if not time_from_user:
            return
        time_from_user = time_from_user.lower()
        matches = re.match(regex, time_from_user)

        if not matches:
            self.speak_dialog('could.not.parse.time')
            return

        matches = matches.groupdict()
        hour = int(matches['hour'])
        minute = int(matches['minute'])
        pm = matches['time_of_day'] == 'pm'

        hour = hour % 12
        hour += 12 if pm else 0

        return hour, minute

    def _generate_cronstring(self, days, hour, minute):
        return '{m} {h} * * {d}'.format(m=minute, h=hour, d=days)

def create_skill():
    return MycroftRoutineSkill()
