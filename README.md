## Mycroft Routine Skill
Create, run, and schedule lists of Mycroft commands

## Description 
Create named rountines, which are lists of Mycroft commands, that can be run by name, and scheduled to run at particular times.

## Examples

### Create a routine
    *User:*    "Create routine"
    *Mycroft:* "What would you like to name it?"
    *User:*    "Morning"
    *Mycroft:* "What is the first task?"
    *User:*    "Turn on the lights."
    *Mycroft:* "What next?"
    *User:*    "Say time to get up."
    *Mycroft:* "What next?"
    *User:*    "Tell me the time."
    *Mycroft:* "What next?"
    *User:*    "Tell me the weather."
    *Mycroft:* "What next?"
    *User:*    "That's all."
    *Mycroft:* "Morning has been created"
    
### Schedule a routine
    *User:*    "Schedule routine morning"
    *Mycroft:* "Which days of the week would you like it to run?"
    *User:*    "Monday Tuesday Wednesday Thursday Friday"
    *Mycroft:* "At what time?"
    *User:*    "7:45 a.m."
    *Mycroft:* "Morning has been schedule"

### Simple commands

* Run routine morning
* List routines
* Describe routine morning
* Disable morning routine
* Enable morning routine
* Delete morning routine

### Notes

**Do not put the name of the routine into one of the commands**. For example, if you create a routine called 'morning,' do not have 'say good morning' as one of the commands. Mycroft may pickup on the name of the routine, and try to run it over again, ultimately creating an infinite loop where the routine continually triggers itself.

## Credits 
* @ChristopherRogers1991
* @gras64 (German translation)


## Short Demos

Skill: https://youtu.be/71RwUTnGJbI

GUI: https://youtu.be/YlHHmi-er7A

## Instalation

### MSM

    msm install https://github.com/ChristopherRogers1991/mycroft_routine_skill.git

### Manual install

1. Clone this repo into your third party skills folder (the current default is `/opt/mycroft/skills`; check your global/local mycroft.conf files if you have issues)
  * `cd /opt/mycroft/skills && git clone https://github.com/ChristopherRogers1991/mycroft_routine_skill.git`
2. `cd` into the resulting `mycroft_routine_skill` directory
  * `cd ~/.mycroft/skills/mycroft_routine_skill`
3. If your mycroft instance runs in a virtual environment, activate it
  * `source <mycroft-core>/.venv/bin/activate`
4. Install the required python libraries
  * `pip install -r requirements.txt`

## Configuration

If you'd like to manually edit your routines, look for `~/.config/mycroft/skills/MycroftRoutineSkill/routines2.json`.

The schedules are fed to [APScheduler](https://apscheduler.readthedocs.io/en/v3.5.1/modules/triggers/cron.html)
as a cronstring. Note that in APScheduler cronstrings, days of the week start on Monday, so 0 is Monday, and 6
is Sunday.

The finished file should be valid json. If you have issues, use http://jsonlint.com/ to validate the json.

