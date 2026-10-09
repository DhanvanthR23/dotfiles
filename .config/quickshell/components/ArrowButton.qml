import "../config"
import QtQuick

Item {
    id: root

    property string label
    property int nudge: 0 // px the arrow slides toward on hover

    signal clicked()

    implicitWidth: 32 // generous hitbox
    implicitHeight: 32

    // hover bubble
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Theme.surfaceAlt
        opacity: hover.hovered ? 1 : 0
        scale: tap.pressed ? 0.88 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.animPress
            }

        }

    }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: hover.hovered ? Theme.accent : Theme.textMuted
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }

        }

        transform: Translate {
            x: hover.hovered ? root.nudge : 0

            Behavior on x {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.OutCubic
                }

            }

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

}
