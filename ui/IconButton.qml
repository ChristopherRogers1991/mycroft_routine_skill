import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4

BaseButton {
    function makeIconSource(pngName) {
        return Qt.resolvedUrl("icons/pngs/" + pngName + ".png")
    }

    property var source

    Layout.alignment: Qt.AlignRight
    Layout.preferredWidth: 50
    Layout.preferredHeight: 50
    radius: 3
    icon.width: 100
    icon.height: 100
    icon.color: "#5C5C5C"
    icon.source: makeIconSource(source)
}