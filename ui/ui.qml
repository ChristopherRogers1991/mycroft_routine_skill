import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: root
    property var testvar: sessionData.testvar
    ColumnLayout {
    Text {
        id: helloText
        text: testvar
        y: 30
        anchors.horizontalCenter: page.horizontalCenter
        font.pointSize: 24; font.bold: true
    }
    Button {
        height: 100
        width: 100
        text: "Click Me"
        onClicked: {
            triggerGuiEvent("skill.mycroft_routine_skill.button_clicked", {})
        }
    }
    }
}