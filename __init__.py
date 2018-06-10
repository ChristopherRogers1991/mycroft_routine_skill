from adapt.intent import IntentBuilder
from mycroft.skills.core import MycroftSkill, intent_handler
from mycroft.util.log import getLogger
from websocket import create_connection
import json


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

    @intent_handler(IntentBuilder("").require("Create").require("Routine"))
    def _create_routine(self, message):
        name = self.get_response("name.it").lower()
        if name == "cancel":
            return
        first_task = self.get_response("first.task")
        if first_task == "cancel":
            return
        tasks = [first_task]
        while True:
            task = self.get_response("next").lower()
            if task == "cancel":
                return
            if task == "that's all" or task == "that's it":
                break
            tasks.append(task)
        self._routines[name] = tasks
        self._write_routine_data()
        self._register_routine(name)

    @intent_handler(IntentBuilder("").optionally("Run").require("RoutineName"))
    def _run_routine(self, message):
        name = message.data["RoutineName"]
        for task in self._routines[name]:
            send_message(task)


def create_skill():
    return MycroftRoutineSkill()
