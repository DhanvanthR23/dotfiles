pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string mode: "off"      // what the user picked: "off" | "now" | "auto"
    property string active: "off"    // what is actually running
    readonly property bool enabled: mode !== "off"

    readonly property int temperature: 4000
    readonly property string latitude: "11.0"
    readonly property string longitude: "77.0"

    function cycle() {
        mode = mode === "off" ? "now" : mode === "now" ? "auto" : "off"
    }

    // let the old process die before starting the next one
    onModeChanged: { active = "off"; settle.restart() }
    Timer { id: settle; interval: 50; onTriggered: root.active = root.mode }

    // warm right now: pretend sunset was 45 min ago
    Process {
        running: root.active === "now"
        command: ["bash", "-c",
            "exec wlsunset -T 6500 -t " + root.temperature
            + " -s $(date -d '-45 minutes' +%H:%M)"
            + " -S $(date -d '+12 hours' +%H:%M)"]
    }

    // real schedule from location
    Process {
        running: root.active === "auto"
        command: ["wlsunset", "-T", "6500", "-t", String(root.temperature),
                  "-l", root.latitude, "-L", root.longitude]
    }
}
