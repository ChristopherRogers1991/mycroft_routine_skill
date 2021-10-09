import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

/**
* Renders a list with a sentinel item. The `rowComponent` will
* be rendered on each standard (non-sentinel) row, and receives
* the data it should render as a value valled `item`.
*/

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

    property Component rowComponent
    property Component sentinelComponent

    // A list containing values that will be passed to the rowComponent
    property var items

    ListView {
        id: list
        model: indexList(addSentinel(items))
        spacing: 20
        anchors.fill: parent
        anchors.topMargin: 100
        delegate: Loader {
            property var item: modelData[1]
            property var index: modelData[0]
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(800, parent.width * 0.8)
            sourceComponent: item == "__sentinel__" ? sentinelComponent : rowComponent
        }
    }
}