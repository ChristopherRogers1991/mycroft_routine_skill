import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4

BaseButton {
    property var buttonText

    contentItem: Text {
        text: buttonText
        font.capitalization: Font.Capitalize
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}