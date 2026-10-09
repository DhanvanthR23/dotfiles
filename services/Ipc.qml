import "../config"
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    // per-screen popups listen to these and react only if the name matches
    signal launcherToggle(string screenName)
    signal controlToggle(string screenName)

    IpcHandler {
        target: "idle"

        function toggle(): void { Idle.toggle(); }
    }

    IpcHandler {
        target: "picker"

        function toggle(): void { Picker.toggle(""); }
        function show(): void { Picker.show(""); }
        function hide(): void { Picker.hide(); }
    }

    IpcHandler {
        target: "session"

        function toggle(): void { Session.toggle(""); }
        function show(): void { Session.show(""); }
        function hide(): void { Session.hide(); }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void { Clip.toggle(""); }
        function show(): void { Clip.show(""); }
        function hide(): void { Clip.hide(); }
    }

    IpcHandler {
        target: "theme"

        function reload(): void { Theme.reload(); }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.launcherToggle(Picker.focusedOutput()); }
    }

    IpcHandler {
        target: "control"

        function toggle(): void { root.controlToggle(Picker.focusedOutput()); }
    }

    IpcHandler {
        target: "notifs"

        function clear(): void { Notifs.clearAll(); }
    }

    IpcHandler {
        target: "updates"

        function run(): void { Updates.run(); }
        function check(): void { Updates.check(true); }
    }

    IpcHandler {
        target: "osd"

        function volume(): void { Osd.volume(); }
        function brightness(): void { Osd.brightness(); }
        function caps(): void { Osd.lock("capslock"); }
        function num(): void { Osd.lock("numlock"); }
    }
}
