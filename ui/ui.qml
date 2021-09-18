import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate{
    id: root
    property var routinesModel: sessionData.routinesModel

    ListView {
        id: list
        model: routinesModel
        width: 500
        height: 500
        delegate: Kirigami.BasicListItem {
            label: "Item: " + modelData
        }
    }
}