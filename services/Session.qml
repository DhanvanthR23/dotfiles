import "../config"
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool open: false
    property string screenName: ""
    property string query: ""
    property int selected: 0
    readonly property string needle: query.trim().toLowerCase()
    readonly property var actions: [
        { "label": "Lock", "cmd": [Idle.lockScript] },
        { "label": "Logout", "cmd": ["niri", "msg", "action", "quit", "--skip-confirmation"] },
        { "label": "Suspend", "cmd": ["systemctl", "suspend"] },
        { "label": "Reboot", "cmd": ["systemctl", "reboot"] },
        { "label": "Shutdown", "cmd": ["systemctl", "poweroff"] }
    ]
    readonly property var results: actions.filter((a) => {
        return a.label.toLowerCase().includes(needle);
    })

    function show(name) {
        screenName = name || Picker.focusedOutput();
        open = true;
    }

    function hide() {
        open = false;
        query = "";
        selected = 0;
    }

    function toggle(name) {
        if (open)
            hide();
        else
            show(name);
    }

    function move(delta) {
        const n = results.length;
        if (n > 0)
            selected = (selected + delta + n) % n;
    }

    // returns true if something ran
    function activateSelected() {
        const r = results[selected];
        if (!r)
            return false;
        hide();
        Quickshell.execDetached(r.cmd);
        return true;
    }

    onQueryChanged: selected = 0

    // qs ipc call session toggle | show | hide
    IpcHandler {
        target: "session"

        function toggle(): void { root.toggle(""); }
        function show(): void { root.show(""); }
        function hide(): void { root.hide(); }
    }
}
