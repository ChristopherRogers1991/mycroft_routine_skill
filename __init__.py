from adapt.intent import IntentBuilder
from mycroft.skills.core import MycroftSkill, intent_handler
from mycroft.util.log import getLogger
from websocket import create_connection
import json
from os.path import join, dirname, abspath


__author__ = 'ChristopherRogers1991'

LOGGER = getLogger(__name__)
URL_TEMPLATE = "{scheme}://{host}:{port}{path}"
ROUTINES_FILENAME = "routines.json"

def send_message(message, host="localhost",
                 port=8181, path="/core", scheme="ws"):
    payload = json.dumps({
        "type": "recognizer_loop:utterance",
        "context": "",
        "data": {
            "utterances": [message]
        }
    })
    url = URL_TEMPLATE.format(scheme=scheme, host=host,
                              port=str(port), path=path)
    ws = create_connection(url)
    ws.send(payload)
    ws.close()


class MycroftRoutineSkill(MycroftSkill):

    def __init__(self):
        super(MycroftRoutineSkill, self).__init__(name="MycroftRoutineSkill")

    def initialize(self):
        self._routines = self._load_routine_data()
        self._register_routines()

        path = dirname(abspath(__file__))
        path_to_stop_words = join(path, 'vocab', self.lang, 'ThatsAll.voc')
        self._stop_words = self._lines_from_path(path_to_stop_words)
        path_to_cancel_words = join(path, 'vocab', self.lang, 'Cancel.voc')
        self._cancel_words = self._lines_from_path(path_to_cancel_words)

    def _lines_from_path(self, path):
        with open(path, 'r') as file:
            lines = [line.strip().lower() for line in file]
            return lines

    def _load_routine_data(self):
        try:
            with self.file_system.open(ROUTINES_FILENAME, 'r') as conf_file:
                return json.loads(conf_file.read())
        except FileNotFoundError:
            log_message = "Routines file not found."
        except PermissionError:
            log_message = "Permission denied when reading routines file."
        except json.decoder.JSONDecodeError:
            log_message = "Error decoding json from routines file."
        log_message += " Initializing empty dictionary."
        return {}

    def _register_routines(self):
        for routine in self._routines:
            self._register_routine(routine)

    def _register_routine(self, name):
        self.register_vocabulary(name, "RoutineName")

    def _write_routine_data(self):
        with self.file_system.open(ROUTINES_FILENAME, 'w') as conf_file:
            conf_file.write(json.dumps(self._routines))

    @intent_handler(IntentBuilder("CreateRoutine").require("Create").require("Routine"))
    def _create_routine(self, message):
        name = self.get_response("name.it").lower()
        if name in self._cancel_words:
            return
        first_task = self.get_response("first.task")
        if first_task in self._cancel_words:
            return
        tasks = [first_task]
        while True:
            task = self.get_response("next").lower()
            if not task or task in self._cancel_words:
                return
            if task in self._stop_words:
                break
            tasks.append(task)
        self._routines[name] = tasks
        self._write_routine_data()
        self._register_routine(name)
        self.speak_dialog('created', data={"name": name})

    @intent_handler(IntentBuilder("RunRoutine").optionally("Run").require("RoutineName"))
    def _run_routine(self, message):
        name = message.data["RoutineName"]
        for task in self._routines[name]:
            send_message(task)

    @intent_handler(IntentBuilder("ListRoutine").require("List").require("Routines"))
    def _list_routines(self, message):
        if not self._routines:
            self.speak_dialog('no.routines')
            return
        routines = ". ".join(self._routines.keys())
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
        tasks = ". ".join(self._routines[name])
        self.speak_dialog('describe', data={"name": name})
        self.speak(tasks)



def create_skill():
    return MycroftRoutineSkill()
