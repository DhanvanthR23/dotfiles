import QtQuick
import Quickshell
import Niri
pragma Singleton

Singleton {
    id: root

    readonly property var workspaces: niri.workspaces
    readonly property var windows: niri.windows
    property bool connected: false

    // output of the focused workspace, "" if unknown
    function focusedOutput() {
        const m = niri.workspaces;
        for (let i = 0; i < m.count; i++) {
            const w = m.get(i);
            if (w.isFocused)
                return w.output;
        }
        return "";
    }

    function focusWorkspace(id) {
        const r = niri.focusWorkspaceById(id);
        if (!r.ok)
            console.warn("niri focus failed:", r.error);
    }

    Component.onCompleted: niri.connect()

    Niri {
        id: niri

        onConnected: root.connected = true
        onDisconnected: {
            root.connected = false;
            retry.start();
        }
        onErrorOccurred: (e) => console.warn("niri:", e)
    }

    // niri restarted or the socket dropped: keep trying
    Timer {
        id: retry

        interval: 2000
        repeat: true
        onTriggered: {
            if (niri.connect())
                stop();
        }
    }
}
