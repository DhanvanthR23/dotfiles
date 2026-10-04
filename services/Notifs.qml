pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property bool toastVisible: false
    property string toastApp: ""
    property string toastSummary: ""
    property string toastBody: ""
    property int toastUrgency: 1
    readonly property bool toastCritical: toastUrgency === NotificationUrgency.Critical
    readonly property bool toastLow: toastUrgency === NotificationUrgency.Low
    readonly property var all: server.trackedNotifications
    readonly property int count: all.values.length
    readonly property var newestFirst: all.values.slice().reverse()

    function isCritical(n) { return n.urgency === NotificationUrgency.Critical }
    function isLow(n) { return n.urgency === NotificationUrgency.Low }

    function dismiss(n) { n.dismiss() }

    function clearAll() {
        for (const n of all.values.slice()) n.dismiss()
    }
    // timeout is in ms; -1 or 0 = app has no preference
    function durationFor(timeout, urgency) {
        if (timeout > 0) return timeout
        if (urgency === NotificationUrgency.Critical) return 5000
        if (urgency === NotificationUrgency.Low) return 1500
        return 2500
    }

    function show(app, summary, body, urgency, timeout) {
        toastApp = app
        toastSummary = summary
        toastBody = body
        toastUrgency = urgency
        hideTimer.interval = durationFor(timeout, urgency)
        hideTimer.restart()
        toastVisible = true
    }

    function hideToast() {
        toastVisible = false
        hideTimer.stop()
    }

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true
            root.show(notification.appName, notification.summary, notification.body,
                      notification.urgency, notification.expireTimeout)
        }
    }

    Timer {
        id: hideTimer
        onTriggered: root.hideToast()
    }
}
