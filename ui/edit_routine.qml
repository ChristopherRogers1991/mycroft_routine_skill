import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

ListViewWithSentinel {
    property var routineName: sessionData.routineName
    property var tasks: JSON.parse(sessionData.tasks)

    headerComponent: headerComponent
    rowComponent: taskComponent
    sentinelComponent: sentinelComponent
    items: tasks

    Component {
        id: headerComponent
        BaseText {
            text: routineName
        }
    }

    Component {
        id: taskComponent
        RowLayout {
            BaseText {
                text: item
            }
            IconButton {
                id: "edit"
                icon.name: "edit"
                source: "mic"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.edit_task",
                    {"RoutineName": routineName, "TaskIndex": index})
                }
            }
            IconButton {
                id: "up"
                icon.name: "up"
                source: "up"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.move_task",
                    {"RoutineName": routineName,
                     "TaskIndex": index,
                     "Direction": "up"})
                }
            }
            IconButton {
                id: "down"
                icon.name: "down"
                source: "down"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.move_task",
                    {"RoutineName": routineName,
                     "TaskIndex": index,
                     "Direction": "down"})
                }
            }
            IconButton {
                id: "delete"
                icon.name: "delete"
                source: "delete"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.delete_task",
                    {"RoutineName": routineName, "TaskIndex": index})
                }
            }
        }

    }

    Component {
        id: sentinelComponent
        TextButton {
            id: add
            buttonText: "+"
            onClicked: {
                triggerGuiEvent("skill.mycroft_routine_skill.add_task",
                {"RoutineName": routineName})
            }
        }
    }

}
