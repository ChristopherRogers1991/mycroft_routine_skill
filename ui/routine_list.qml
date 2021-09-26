import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate{
    id: root
    property var routinesModel: JSON.parse(sessionData.routinesModel)
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
                Layout.alignment: Qt.AlignLeft
                Layout.rightMargin: 10
                Layout.fillWidth: true
                palette {
                    button: "white"
                }
                text: modelData
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.run_routine_button_clicked", {"RoutineName": modelData})
                }
            }
            Button {
                id: edit
                Layout.alignment: Qt.AlignRight
                palette {
                    button: "white"
                }
                text: "Edit"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.edit_routine_button_clicked", {"RoutineName": modelData})
                }
            }
            Button {
                id: schedule
                Layout.alignment: Qt.AlignRight
                palette {
                    button: "white"
                }
                text: "Rename"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.rename_routine_button_clicked", {"RoutineName": modelData})
                }
            }
        }
    }
}