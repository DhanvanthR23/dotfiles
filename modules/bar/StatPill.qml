import QtQuick
import "../../config"

Rectangle {
    id: root
    property string icon
    property string value
    property color valueColor: Theme.text

    property string sample   // widest expected value, locks the pill width

    TextMetrics {
        id: sampleMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: root.sample
    }

    implicitWidth: content.implicitWidth + Theme.padding * 2
    implicitHeight: Theme.pillHeight
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
            font.family: Theme.iconFont
            font.pixelSize: Theme.fontSize
        }
        Text {
            id: valueLabel
            width: Math.max(implicitWidth, sampleMetrics.width)
            horizontalAlignment: Text.AlignHCenter
            text: root.value
            color: root.valueColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
    HoverHandler {
        id: hover
    }
}
