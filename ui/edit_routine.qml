import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

ListViewWithSentinel {
    property var routineName: sessionData.routineName
    property var tasks: JSON.parse(sessionData.tasks)

    rowComponent: taskComponent
    sentinelComponent: sentinelComponent
    items: tasks

    Component {
        id: taskComponent
        RowLayout {
            Text {
                Layout.alignment: Qt.AlignLeft
                Layout.rightMargin: 10
                Layout.fillWidth: true
                text: item
                font.pointSize: 20
                font.bold: true
                color: "white"
            }
            IconButton {
                id: "edit"
                icon.name: "edit"
                source: "mic"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.edit_task_button_clicked",
                    {"RoutineName": routineName, "TaskIndex": index})
                }
            }
            IconButton {
                id: "up"
                icon.name: "up"
                source: "up"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.move_task_button_clicked",
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
                    triggerGuiEvent("skill.mycroft_routine_skill.move_task_button_clicked",
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
                    triggerGuiEvent("skill.mycroft_routine_skill.delete_task_button_clicked",
                    {"RoutineName": routineName, "TaskIndex": index})
                }
            }
        }

    }

    Component {
        id: sentinelComponent
        BaseButton {
            id: add
            text: "+"
            onClicked: {
                triggerGuiEvent("skill.mycroft_routine_skill.add_task_button_clicked",
                {"RoutineName": routineName})
            }
        }
    }

}
