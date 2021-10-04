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
    property var routineName: sessionData.routineName
    property var tasks: addSentinel(JSON.parse(sessionData.tasks))
    ListView {
        id: list
        model: tasks
        spacing: 20
        anchors.fill: parent
        anchors.topMargin: 100
        delegate: Loader {
            property var task: modelData
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(600, parent.width * 0.8)
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
                icon.name: "edit"
                icon.source: "icons/pngs/mic.png"
                icon.color: "#5C5C5C"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.edit_task_button_clicked",
                    {"RoutineName": routineName, "TaskIndex": list.currentIndex})
                }
            }
        }

    }

    Component {
        id: sentinelComponent
        Button {
            id: add
            palette {
                button: "white"
            }
            text: "+"
            onClicked: {
                triggerGuiEvent("skill.mycroft_routine_skill.add_task_button_clicked",
                {"RoutineName": routineName})
            }
        }
    }

}
