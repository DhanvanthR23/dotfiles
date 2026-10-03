import QtQuick
import "../../config"

Rectangle {
    id: root
    property string icon
    property string title
    property string subtitle
    property bool active: false
    signal clicked()

    implicitHeight: 52
    radius: 14
    color: active ? Theme.accent : Theme.surfaceAlt
    border.width: 1
    border.color: active ? Theme.accent
                : hover.hovered ? Theme.accent
                : Theme.border
    scale: tap.pressed ? 0.96 : 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 80 } }

    Text {
        id: iconLabel
        anchors {
            left: parent.left
            leftMargin: Theme.padding
            verticalCenter: parent.verticalCenter
        }
        text: root.icon
        color: root.active ? Theme.bg : Theme.accent
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize + 6
    }

    Column {
        anchors {
            left: iconLabel.right
            leftMargin: 10
            right: parent.right
            rightMargin: Theme.padding
            verticalCenter: parent.verticalCenter
        }

        Text {
            width: parent.width
            text: root.title
            color: root.active ? Theme.bg : Theme.text
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.bold: true
        }
        Text {
            width: parent.width
            text: root.subtitle
            color: root.active ? Theme.bg : Theme.textMuted
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
        }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { id: tap; onTapped: root.clicked() }
}
