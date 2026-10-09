import "../config"
import QtQuick

Rectangle {
    id: root

    property bool hoverable: true
    readonly property bool hovered: hover.hovered

    implicitHeight: Theme.pillHeight
    radius: height / 2
    color: hoverable && hovered ? Theme.surfaceAlt : Theme.surface
    border.width: 1
    border.color: Theme.border

    HoverHandler {
        id: hover
    }

}
