import "../config"
import QtQuick

Rectangle {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool active: false

    signal clicked()

    implicitHeight: 52
    radius: Theme.radiusItem
    color: active ? Theme.accent : Theme.surfaceAlt
    border.width: 1
    border.color: active ? Theme.accent : hover.hovered ? Theme.accent : Theme.border
    scale: tap.pressed ? 0.96 : 1

    Text {
        id: iconLabel

        text: root.icon
        color: root.active ? Theme.bg : Theme.accent
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSizeLarge

        anchors {
            left: parent.left
            leftMargin: Theme.padding
            verticalCenter: parent.verticalCenter
        }

    }

    Column {
        anchors {
            left: iconLabel.right
            leftMargin: Theme.gap
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
            font.pixelSize: Theme.fontSmall
            font.bold: true
        }

        Text {
            width: parent.width
            text: root.subtitle
            color: root.active ? Theme.bg : Theme.textMuted
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
        }

    }

    HoverHandler {
        id: hover

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tap

        onTapped: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.animFast
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.animPress
        }

    }

}
