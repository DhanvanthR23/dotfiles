import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property bool open: false
    property string screenName: ""
    property string view: "themes" // "themes" | "walls"

    // output of the focused niri workspace, else the first screen
    // remove: import Quickshell.Niri
    function focusedOutput() {
        return NiriService.focusedOutput() || (Quickshell.screens[0] ? Quickshell.screens[0].name : "");
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

}
