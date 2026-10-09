import "../../components"
import "../../config"
import "../../services"
import QtQuick

Pill {
    id: root

    readonly property bool toast: Notifs.toastVisible
    property real expand: 0 // 0..1, driven by the calendar popup
    readonly property real idleWidth: clockLabel.implicitWidth + Theme.padding * 2
    property real launcherExpand: 0 // 0..1, driven by the launcher popup
    readonly property real baseWidth: toast ? Theme.toastWidth : idleWidth + (Theme.toastWidth - idleWidth) * expand
    property real sessionExpand: 0 // 0..1, driven by the session popup
    readonly property real preSessionWidth: baseWidth + (Theme.launcherWidth - baseWidth) * launcherExpand

    implicitWidth: preSessionWidth + (Theme.sessionWidth - preSessionWidth) * sessionExpand
    implicitHeight: toast ? Theme.toastHeight : Theme.pillHeight
    border.color: toast && Notifs.toastCritical ? Theme.error : Theme.border
    clip: true

    // normal state: the clock
    Text {
        id: clockLabel

        anchors.centerIn: parent
        text: Time.time
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        opacity: root.toast ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
            }

        }

    }

    // toast state
    Item {
        anchors.fill: parent
        opacity: root.toast ? 1 : 0

        NotifAvatar {
            id: avatar

            app: Notifs.toastApp
            critical: Notifs.toastCritical
            low: Notifs.toastLow

            anchors {
                left: parent.left
                leftMargin: 6
                verticalCenter: parent.verticalCenter
            }

        }

        Column {
            anchors {
                left: avatar.right
                leftMargin: Theme.gap
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
                id: toastBody

                visible: Notifs.toastProgress < 0
                width: parent.width
                text: Notifs.toastBody
                color: Theme.textMuted
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }

            Item {
                visible: Notifs.toastProgress >= 0
                width: parent.width
                height: toastBody.implicitHeight

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Theme.border

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, Notifs.toastProgress))
                        height: parent.height
                        radius: parent.radius
                        color: Theme.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.animPress
                            }

                        }

                    }

                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
            }

        }

    }

    // update badge, hidden while a toast is showing
    UpdateDot {
        visible: Updates.count > 0 && !root.toast

        anchors {
            top: parent.top
            right: parent.right
            topMargin: 2
            rightMargin: 4
        }

    }

    // click anywhere on a toast to dismiss it
    TapHandler {
        enabled: root.toast
        onTapped: Notifs.hideToast()
    }

    Behavior on implicitWidth {
        enabled: root.expand === 0 && root.launcherExpand === 0 && root.sessionExpand === 0

        NumberAnimation {
            duration: Theme.animDuration
            easing.type: Easing.OutCubic
        }

    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.animDuration
            easing.type: Easing.OutCubic
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.animFast
        }

    }

}
