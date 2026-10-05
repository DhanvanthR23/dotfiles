import "../config"
import QtQuick

Row {
    id: root

    property string icon
    property string value
    property color valueColor: Theme.text
    property string sample // widest expected value, locks the width

    spacing: 6

    TextMetrics {
        id: sampleMetrics

        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: root.sample
    }

    Text {
        text: root.icon
        color: Theme.accent
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize
    }

    Text {
        width: Math.max(implicitWidth, sampleMetrics.width)
        horizontalAlignment: Text.AlignHCenter
        text: root.value
        color: root.valueColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
