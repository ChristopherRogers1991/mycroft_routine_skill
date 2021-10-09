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
            BaseButton {
                Layout.alignment: Qt.AlignLeft
                Layout.rightMargin: 10
                Layout.fillWidth: true
                text: routine
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.run_routine_button_clicked", messageData)
                }
            }
            IconButton {
                icon.name: "rename"
                source: "mic"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.rename_routine_button_clicked", messageData)
                }
            }
            IconButton {
                icon.name: "edit"
                source: "edit"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.edit_routine_button_clicked", messageData)
                }
            }
            IconButton {
                icon.name: "delete"
                source: "delete"
                onClicked: {
                    triggerGuiEvent("skill.mycroft_routine_skill.delete_routine_button_clicked", messageData)
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
                triggerGuiEvent("skill.mycroft_routine_skill.add_routine_button_clicked", {})
            }
        }
    }
}