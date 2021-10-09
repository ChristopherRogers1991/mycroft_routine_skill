import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import Mycroft 1.0 as Mycroft

ListViewWithSentinel {
    property var routines: JSON.parse(sessionData.routinesModel)

    rowComponent: routineComponent
    sentinelComponent: sentinelComponent
    items: routines

    Component {
        id: routineComponent
        RowLayout {
            property var routine: item
            property var messageData: {"RoutineName": routine}
            TextButton {
                Layout.alignment: Qt.AlignLeft
                Layout.rightMargin: 10
                Layout.fillWidth: true
                buttonText: routine
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.run_routine", messageData)
                }
            }
            IconButton {
                icon.name: "rename"
                source: "mic"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.rename_routine", messageData)
                }
            }
            IconButton {
                icon.name: "edit"
                source: "edit"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.edit_routine", messageData)
                }
            }
            IconButton {
                icon.name: "delete"
                source: "delete"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.delete_routine", messageData)
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
                triggerGuiEvent("skill.mycroft_routine_skill.add_routine", {})
            }
        }
    }
}