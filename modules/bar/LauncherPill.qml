import "../../components"
import "../../config"
import QtQuick

Pill {
    id: root

    property string icon: "󰍉"

    signal clicked()

    implicitWidth: Theme.pillHeight // 28px circle, since Pill's radius is height / 2

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.hovered ? Theme.accent : Theme.text
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
