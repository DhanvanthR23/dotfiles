import "../../config"
import "../../services"
import QtQuick

Item {
    id: root

    property real shakeX: 0
    readonly property font clockFont: Qt.font({
        "family": "SF Pro Display",
        "pixelSize": 160,
        "weight": Font.Bold,
        "letterSpacing": 4
    })

    Image {
        anchors.fill: parent
        source: Lock.wallpaper !== "" ? "file://" + Lock.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        cache: true
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.45
    }

    Connections {
        target: Lock

        function onWrong() {
            shake.restart();
        }
    }

    SequentialAnimation {
        id: shake

        NumberAnimation { target: root; property: "shakeX"; to: -12; duration: 50 }
        NumberAnimation { target: root; property: "shakeX"; to: 12; duration: 70 }
        NumberAnimation { target: root; property: "shakeX"; to: -8; duration: 60 }
        NumberAnimation { target: root; property: "shakeX"; to: 0; duration: 60 }
    }

    Rectangle {
        width: 44
        height: 44
        radius: 22
        x: (root.width - width) / 2 + root.shakeX
        y: Theme.gap + Theme.barHeight / 2 - height / 2
        color: Theme.surface
        border.width: 1
        border.color: Theme.border

        Text {
            anchors.centerIn: parent
            text: "\udb80\udf3e"
            color: Theme.accent
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
    }

    Item {
        id: clock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height - height - root.height * 0.02
        width: face.implicitWidth
        height: face.implicitHeight

        Text {
            y: 6
            text: Time.time
            font: root.clockFont
            color: "black"
            opacity: 0.35
        }

        Text {
            id: face

            text: Time.time
            font: root.clockFont
            color: Qt.alpha(Theme.text, 0.85)
        }
    }

    Rectangle {
        width: 240
        height: 44
        radius: 22
        x: (root.width - width) / 2 + root.shakeX
        y: clock.y - height - 16
        color: Theme.surface
        border.width: 1
        border.color: Theme.border
        opacity: Lock.password.length > 0 ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast }
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: Lock.password.length

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.text
                }
            }
        }
    }
}
