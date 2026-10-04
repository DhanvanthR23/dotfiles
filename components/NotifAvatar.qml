import "../config"
import QtQuick

Rectangle {
    id: root

    property string app: ""
    property bool critical: false
    property bool low: false

    width: 28
    height: 28
    radius: height / 2
    color: Theme.surfaceAlt // override at the call site when the background differs

    Text {
        anchors.centerIn: parent
        text: root.app.charAt(0).toUpperCase()
        color: root.critical ? Theme.error : root.low ? Theme.textMuted : Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

}
