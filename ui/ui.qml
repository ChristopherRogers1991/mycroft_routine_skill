import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate{
    id: root
    property var routinesModel: sessionData.routinesModel
    ListView {
        id: list
        model: routinesModel
        spacing: 20
        anchors.fill: parent
        anchors.topMargin: 100
        delegate: RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(600, parent.width * 0.8)
            Button {
                anchors.right: edit.left
                anchors.left: parent.left
                anchors.rightMargin: 10
                palette {
                    button: "white"
                }
                text: modelData
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.button_clicked", {"RoutineName": modelData})
                }
            }
            Button {
                id: edit
                anchors.right: parent.right
                palette {
                    button: "white"
                }
                text: "Edit"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.button_clicked", {"RoutineName": modelData})
                }
            }
        }
    }
}