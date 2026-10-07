import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Niri
pragma Singleton

Singleton {
    id: root

    property bool open: false
    property string screenName: ""
    property string view: "themes" // "themes" | "walls"

    // output of the focused niri workspace, else the first screen
    function focusedOutput() {
        try {
            const ws = Niri.workspaces.values.find((x) => {
                return x.focused;
            });
            if (ws)
                return ws.output;
        } catch (e) {
        }
        return Quickshell.screens[0] ? Quickshell.screens[0].name : "";
    }

    function show(name) {
        screenName = name || focusedOutput();
        Themes.refresh();
        open = true;
    }

    function hide() {
        open = false;
    }

    function toggle(name) {
        if (open)
            hide();
        else
            show(name);
    }

    // qs ipc call picker toggle | show | hide
    IpcHandler {
        target: "picker"

        function toggle(): void {
            root.toggle("");
        }

        function show(): void {
            root.show("");
        }

        function hide(): void {
            root.hide();
        }
    }

}
