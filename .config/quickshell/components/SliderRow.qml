import "../config"
import QtQuick

Item {
    id: root

    property string icon
    property real value: 0 // 0..1, driven by the service
    property bool muted: false
    property bool interactive: true
    property real dragValue: 0
    readonly property real shownValue: Math.max(0, Math.min(1, area.pressed ? dragValue : value))

    signal moved(real newValue) // user dragged or clicked: new 0..1
    signal iconClicked()

    implicitHeight: 36

    // icon (click to mute)
    Item {
        id: iconBox

        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: iconHover.hovered ? Theme.accent : Theme.textMuted
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }

            }

        }

        HoverHandler {
            id: iconHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: root.iconClicked()
        }

    }

    Text {
        id: label

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        horizontalAlignment: Text.AlignRight
        text: Math.round(root.shownValue * 100) + "%"
        color: Theme.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        opacity: root.interactive ? 1 : 0.4
    }

    Rectangle {
        id: track

        height: 6
        radius: 3
        opacity: root.interactive ? 1 : 0.4
        color: Theme.surfaceAlt

        anchors {
            left: iconBox.right
            leftMargin: 8
            right: label.left
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: parent.width * root.shownValue
            height: parent.height
            radius: parent.radius
            color: root.muted ? Theme.textMuted : Theme.accent
        }

        Rectangle {
            width: 14
            height: 14
            radius: 7
            x: (parent.width - width) * root.shownValue
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.text
            scale: area.pressed || area.containsMouse ? 1.2 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.animPress
                }

            }

        }

    }

    // taller than the track so it's easy to grab
    MouseArea {
        id: area

        function setFrom(mx) {
            root.dragValue = Math.max(0, Math.min(1, mx / width));
            root.moved(root.dragValue);
        }

        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: (mouse) => {
            return setFrom(mouse.x);
        }
        onPositionChanged: (mouse) => {
            if (pressed)
                setFrom(mouse.x);

        }
        onWheel: (wheel) => {
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.moved(Math.max(0, Math.min(1, root.shownValue + step)));
        }

        anchors {
            fill: track
            topMargin: -10
            bottomMargin: -10
        }

    }

}
