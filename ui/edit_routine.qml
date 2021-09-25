import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate{
    id: root
    property var routineName: sessionData.routineName
    property var tasks: JSON.parse(sessionData.tasks)
    ListView {
        id: list
        model: tasks
        spacing: 20
        anchors.fill: parent
        anchors.topMargin: 100
        delegate: RowLayout {
            property var task: modelData
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(600, parent.width * 0.8)
            Text {
                anchors.right: edit.left
                anchors.left: parent.left
                anchors.rightMargin: 10
                text: task
                font.pointSize: 20
                font.bold: true
                color: "white"
            }
            Button {
                id: edit
                anchors.right: parent.right
                palette {
                    button: "white"
                }
                text: "Edit"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.edit_task_button_clicked",
                    {"RoutineName": routineName, "TaskIndex": list.currentIndex})
                }
            }
        }
    }
}
