import QtQuick
import Quickshell
import Quickshell.Services.Notifications
pragma Singleton

Singleton {
    id: root

    property bool toastVisible: false
    property string toastApp: ""
    property string toastSummary: ""
    property string toastBody: ""
    property int toastUrgency: 1
    property real toastProgress: -1 // -1 = no bar, 0..1 = show a bar
    readonly property bool toastCritical: toastUrgency === NotificationUrgency.Critical
    readonly property bool toastLow: toastUrgency === NotificationUrgency.Low
    readonly property var all: server.trackedNotifications
    readonly property int count: all.values.length
    readonly property var newestFirst: all.values.slice().reverse()
    property bool dnd: false

    // toasts waiting for the pill; OSD-style toasts never wait (see show())
    property var queue: []
    readonly property int maxQueue: 5
    // these replace the current toast instantly, so holding a volume key doesn't pile up a queue
    readonly property var instantApps: ["Volume", "Brightness", "Caps Lock", "Num Lock", "Idle", "Media"]

    function isCritical(n) {
        return n.urgency === NotificationUrgency.Critical;
    }

    function isLow(n) {
        return n.urgency === NotificationUrgency.Low;
    }

    function dismiss(n) {
        n.dismiss();
    }

    function clearAll() {
        queue = [];
        for (const n of all.values.slice()) n.dismiss()
    }

    // timeout is in ms; -1 or 0 = app has no preference
    function durationFor(timeout, urgency) {
        if (timeout > 0)
            return timeout;

        if (urgency === NotificationUrgency.Critical)
            return 5000;

        if (urgency === NotificationUrgency.Low)
            return 1500;

        return 2500;
    }

    function display(t) {
        toastApp = t.app;
        toastSummary = t.summary;
        toastBody = t.body;
        toastUrgency = t.urgency;
        toastProgress = t.progress;
        hideTimer.interval = durationFor(t.timeout, t.urgency);
        hideTimer.restart();
        toastVisible = true;
    }

    function show(app, summary, body, urgency, timeout, progress) {
        const t = {
            "app": app,
            "summary": summary,
            "body": body,
            "urgency": urgency,
            "timeout": timeout,
            "progress": progress === undefined ? -1 : progress
        };
        const instant = progress !== undefined || instantApps.includes(app);
        if (!toastVisible || instant) {
            display(t);
            return ;
        }
        // a critical toast jumps the line, everything else waits its turn
        const next = queue.slice();
        if (urgency === NotificationUrgency.Critical)
            next.unshift(t);
        else
            next.push(t);
        queue = next.slice(0, maxQueue);
    }

    // show the next waiting toast, or hide the pill state when nothing is left
    function hideToast() {
        hideTimer.stop();
        if (queue.length > 0) {
            const next = queue.slice();
            const t = next.shift();
            queue = next;
            display(t);
            return ;
        }
        toastVisible = false;
    }

    NotificationServer {
        id: server

        bodySupported: true
        actionsSupported: true
        imageSupported: true
        onNotification: (notification) => {
            notification.tracked = true; // always keep it in the list
            if (root.dnd && notification.urgency !== NotificationUrgency.Critical)
                return;
            root.show(notification.appName, notification.summary, notification.body, notification.urgency, notification.expireTimeout);
        }
    }

    Timer {
        id: hideTimer

        onTriggered: root.hideToast()
    }

}
