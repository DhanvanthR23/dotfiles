import QtQuick
import "../../services"
import "../../config"

Rectangle {
    id: root

    readonly property bool toast: Notifs.toastVisible

    implicitWidth: toast ? Theme.toastWidth : clockLabel.implicitWidth + Theme.padding * 2
    implicitHeight: toast ? Theme.toastHeight : 28
    radius: height / 2
    color: hover.hovered ? Theme.surfaceAlt : Theme.surface
    border.width: 1
    border.color: toast && Notifs.toastCritical ? Theme.error : Theme.border
    clip: true

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic }
    }
    Behavior on implicitHeight {
        NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic }
    }
    Behavior on border.color {
        ColorAnimation { duration: 120 }
    }

    // normal state: the clock
    Text {
        id: clockLabel
        anchors.centerIn: parent
        text: Time.time
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        opacity: root.toast ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    // toast state
    Item {
        anchors.fill: parent
        opacity: root.toast ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }

        Rectangle {
            id: avatar
            width: 28
            height: 28
            radius: 14
            color: Theme.surfaceAlt
            anchors {
                left: parent.left
                leftMargin: 6
                verticalCenter: parent.verticalCenter
            }

            Text {
                anchors.centerIn: parent
                text: Notifs.toastApp.charAt(0).toUpperCase()
                color: Notifs.toastCritical ? Theme.error
                     : Notifs.toastLow ? Theme.textMuted
                     : Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }

        Column {
            anchors {
                left: avatar.right
                leftMargin: 10
                right: parent.right
                rightMargin: Theme.padding
                verticalCenter: parent.verticalCenter
            }

            Text {
                width: parent.width
                text: Notifs.toastSummary
                color: Theme.text
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
            }
            Text {
                width: parent.width
                text: Notifs.toastBody
                color: Theme.textMuted
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }

    // update badge, hidden while a toast is showing
    Rectangle {
        visible: Updates.count > 0 && !root.toast
        width: 8
        height: 8
        radius: 4
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 2
            rightMargin: 4
        }
        color: Updates.level === "critical" ? Theme.error
             : Updates.level === "warning" ? Theme.warn
             : Theme.accent

        TapHandler {
            margin: 6
            onTapped: Updates.run()
        }
    }

    // click anywhere on a toast to dismiss it
    TapHandler {
        enabled: root.toast
        onTapped: Notifs.hideToast()
    }

    HoverHandler { id: hover }
}
