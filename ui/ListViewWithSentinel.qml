import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import Mycroft 1.0 as Mycroft

/**
* Renders a list with a sentinel item. The `rowComponent` will
* be rendered on each standard (non-sentinel) row, and receives
* the data it should render as a value valled `item`.
*/

Mycroft.Delegate{
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

    property Component headerComponent
    property Component rowComponent
    property Component sentinelComponent

    // A list containing values that will be passed to the rowComponent
    property var items

    /**
    * Trying to get the parent height in the ListView produces a segfault.
    * Getting the parent width works fine, and it works just fine if this
    * is inside a Mycroft.ScrollableDelegate. Unsure why it doesn't work
    * with a Mycroft.Delegate. Getting the height here seems to work fine
    * as a workaround.
    **/
    property int parentHeight: parent.height

    ColumnLayout {
        anchors.fill: parent

        /**
        * The UI shows the user spoken text in the top right corner, and it can
        * overlap the UI. This margin puts our components under that text, so
        * there's never any overlap.
        */
        anchors.topMargin: 70

        Item {
            id: header
            Layout.alignment: Qt.AlignTop, Qt.AlignHCenter
            Layout.preferredWidth: Math.min(800, parent.width * 0.8)
            Loader {
                sourceComponent: headerComponent
            }
        }
        ScrollView {
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            Layout.alignment: Qt.AlignTop, Qt.AlignHCenter
            Layout.preferredWidth: Math.min(800, parent.width * 0.8)
            Layout.preferredHeight: parentHeight - 175
            clip: true
            ListView {
                id: list
                boundsBehavior: Flickable.DragOverBounds
                model: indexList(addSentinel(items))
                spacing: 20
                delegate: Loader {
                    property var item: modelData[1]
                    property var index: modelData[0]
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    sourceComponent: item == "__sentinel__" ? sentinelComponent : rowComponent
                }
            }
        }
    }
}