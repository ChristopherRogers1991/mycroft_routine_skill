import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate{
    id: root
    function addSentinel(items) {
        items.push("__sentinel__")
        return items
    }

    function indexList(items) {
        var newList = []
        for (var i = 0; i < items.length; i++) {
            newList.push([i, items[i]])
        }
        return newList
    }

    property var routineName: sessionData.routineName
    property var tasks: indexList(addSentinel(JSON.parse(sessionData.tasks)))
    ListView {
        id: list
        model: tasks
        spacing: 20
        anchors.fill: parent
        anchors.topMargin: 100
        delegate: Loader {
            property var task: modelData[1]
            property var index: modelData[0]
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(800, parent.width * 0.8)
            sourceComponent: task == "__sentinel__" ? sentinelComponent : taskComponent
        }
    }

    Component {
        id: taskComponent
        RowLayout {
            Text {
                Layout.alignment: Qt.AlignLeft
                Layout.rightMargin: 10
                Layout.fillWidth: true
                text: task
                font.pointSize: 20
                font.bold: true
                color: "white"
            }
            IconButton {
                id: "edit"
                icon.name: "edit"
                icon.source: "icons/pngs/mic.png"
                icon.color: "#5C5C5C"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.edit_task_button_clicked",
                    {"RoutineName": routineName, "TaskIndex": index})
                }
            }
            IconButton {
                id: "up"
                icon.name: "up"
                icon.source: "icons/pngs/up.png"
                icon.color: "#5C5C5C"
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
                icon.source: "icons/pngs/down.png"
                icon.color: "#5C5C5C"
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
                icon.source: "icons/pngs/delete.png"
                icon.color: "#5C5C5C"
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
