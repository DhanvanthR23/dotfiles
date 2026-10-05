import "../config"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
pragma Singleton

Singleton {
    id: root

    readonly property string lockScript: Quickshell.env("HOME") + "/.config/niri/scripts/lock.sh"
    property bool inhibited: false

    function toggle() {
        inhibited = !inhibited;
        Notifs.show("Idle", inhibited ? "Keep awake on" : "Keep awake off", "", 0, 1500);
    }

    // stage 1: screen off, back on at the first input
    IdleMonitor {
        timeout: Settings.idleScreenOff
        onIsIdleChanged: Quickshell.execDetached(["niri", "msg", "action", isIdle ? "power-off-monitors" : "power-on-monitors"])
    }

    // stage 2: lock
    IdleMonitor {
        timeout: Settings.idleLock
        onIsIdleChanged: {
            if (isIdle)
                Quickshell.execDetached([root.lockScript]);
        }
    }
    // --- sleep hooks (hypridle's before_sleep_cmd / after_sleep_cmd) ---
    // delay inhibitor: holds suspend back for a moment so the lock can come up first
    Process {
        id: sleepDelay

        running: true
        command: ["systemd-inhibit", "--what=sleep", "--who=qs-shell", "--why=lock before sleep", "--mode=delay", "sleep", "infinity"]
    }

    Timer {
        id: releaseDelay

        interval: 1000
        onTriggered: sleepDelay.running = false
    }

    // logind announces sleep (true) and wake (false)
    Process {
        running: true
        command: ["dbus-monitor", "--system", "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'"]

        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("boolean true")) {
                    Quickshell.execDetached([root.lockScript]);
                    releaseDelay.start();
                } else if (line.includes("boolean false")) {
                    sleepDelay.running = true; // take the delay lock again for next time
                    Quickshell.execDetached(["niri", "msg", "action", "power-on-monitors"]);
                }
            }
        }
    }

    // lets the Niri keybind reach the shell: qs ipc call idle toggle
    IpcHandler {
        target: "idle"

        function toggle(): void {
            root.toggle();
        }
    }
}
