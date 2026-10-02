import QtQuick
import "../../services"
import "../../config"

Rectangle {
    id: root
    implicitWidth: label.implicitWidth + Theme.padding * 2
    implicitHeight: 28
    radius: height / 2
    color: hover.hovered ? Theme.surfaceAlt : Theme.surface
    border.width: 1
    border.color: Theme.border
    Text{
        id: label
        anchors.centerIn: parent
        text: Time.time
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
    HoverHandler {
        id: hover
    }
    Behavior on color {
        ColorAnimation { duration: 120 }
    }
}
