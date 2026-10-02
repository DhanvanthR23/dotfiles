pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton{
    id: root
    property int count: 0
    readonly property bool checking: checker.running
    readonly property string level: count >= 50 ? "critical" : count >= 25 ? "warning" : count > 0 ? "normal" : "updated"
    function check() {
        if (!checker.running){
            checker.running = true
        }
    }
    Process {
        id: checker
        command: ["bash",Quickshell.shellPath("scripts/update-count.sh")]
        stdout: StdioCollector {
            onStreamFinished: root.count = parseInt(this.text.trim()) || 0
        }
    }
    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.check()
    }
    function run() {
        if (!updater.running)
            updater.running = true
    }
    Process {
        id: updater
        command: ["foot", "-e", "bash", "-c",
            "paru -Syu --sudoloop; echo; echo '  Done. Press any key to close.'; read -n1"]
        onRunningChanged: if (!running) root.check()
    }
    readonly property int urgency: level === "critical" ? 2
                                 : level === "warning" ? 1
                                 : 0
    property int lastCount: 0

    onCountChanged: {
        if (count > lastCount) {
            Notifs.show("Updates", "Updates available",
                        count === 1 ? "1 package" : count + " packages",
                        urgency, -1)
        } else if (count === 0 && lastCount > 0) {
            Notifs.show("Updates", "System is up to date", "", 0, 4000)
        }
        lastCount = count
    }
}
