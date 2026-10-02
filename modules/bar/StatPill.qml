import QtQuick
import "../../config"

Rectangle {
    id: root
    property string icon
    property string value
    property color valueColor: Theme.text

    implicitWidth: content.implicitWidth + Theme.padding * 2
    implicitHeight: 28
    radius: height / 2
    color: hover.hovered ? Theme.surfaceAlt : Theme.surface
    border.width: 1
    border.color: Theme.border
    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6
        Text {
            id: iconLabel
            text: root.icon
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        Text {
            id: valueLabel
            text: root.value
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
    HoverHandler {
        id: hover
    }
}
