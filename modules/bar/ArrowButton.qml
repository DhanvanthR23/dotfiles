import QtQuick
import "../../config"

Item {
    id: root
    property string label
    property int nudge: 0        // px the arrow slides toward on hover
    signal clicked()

    implicitWidth: 32            // hitbox, was ~10px before
    implicitHeight: 32

    // hover bubble
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Theme.surfaceAlt
        opacity: hover.hovered ? 1 : 0
        scale: tap.pressed ? 0.88 : 1
        Behavior on opacity { NumberAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 80 } }
    }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: hover.hovered ? Theme.accent : Theme.textMuted
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize + 4
        Behavior on color { ColorAnimation { duration: 120 } }

        transform: Translate {
            x: hover.hovered ? root.nudge : 0
            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { id: tap; onTapped: root.clicked() }
}
