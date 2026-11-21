import "../../config"
import "../../services"
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var popup
    readonly property real p: popup.progress
    // clock appears in the second part of the animation
    readonly property real m: Math.max(0, Math.min(1, p / 0.4))
    readonly property real clockIn: Math.max(0, Math.min(1, (p - 0.4) / 0.6))
    readonly property font clockFont: Qt.font({
        "family": "SF Pro Display",
        "pixelSize": 160,
        "weight": Font.Bold,
        "letterSpacing": 4
    })
    property real shakeX: 0

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: popup.open && popup.hasKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    Component.onCompleted: input.forceActiveFocus()

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Image {
        anchors.fill: parent
        source: Lock.wallpaper !== "" ? "file://" + Lock.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        cache: true
        opacity: Math.min(1, root.p * 2) // fully covers the windows by halfway
    }

    // dim the wallpaper
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.45 * root.p
    }

    // hidden input: collects keystrokes, the dots below are drawn from its length
    TextInput {
        id: input

        width: 1
        height: 1
        opacity: 0
        focus: true
        echoMode: TextInput.Password
        Keys.onEscapePressed: text = ""
        Keys.onPressed: (e) => {
            if (e.key === Qt.Key_Backspace && (e.modifiers & Qt.ControlModifier)) {
                text = "";
                e.accepted = true;
            }
        }
        onAccepted: Lock.attempt(text)
        onTextChanged: Lock.password = text
    }

    Connections {
        target: Lock

        function onWrong() {
            input.text = "";
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

    // the island: the lock icon
    Rectangle {
        id: island

        readonly property real startW: root.popup.pill.idleWidth

        width: startW + (44 - startW) * root.m
        height: Theme.pillHeight + (44 - Theme.pillHeight) * root.m
        radius: height / 2
        x: (root.width - width) / 2 + root.shakeX
        y: Theme.gap + Theme.barHeight / 2 - height / 2 // keeps the bar's vertical center
        color: Theme.surface
        border.width: 1
        border.color: Theme.border

        // the clock text from the pill fades out...
        Text {
            anchors.centerIn: parent
            text: Time.time
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            opacity: 1 - Math.min(1, root.m * 2.5)
        }

        // ...while the lock icon fades in
        Text {
            anchors.centerIn: parent
            text: "\udb80\udf3e"
            color: Theme.accent
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
            opacity: Math.max(0, root.m * 2.5 - 1.5)
        }
    }

    // hero clock: soft shadow + translucent face
    Item {
        id: clock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height - height - root.height * 0.02 // 7% bottom margin
        width: face.implicitWidth
        height: face.implicitHeight
        opacity: root.clockIn
        transform: Translate { y: 24 * (1 - root.clockIn) }

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

    // password dots, only visible once you start typing
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
