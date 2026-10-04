import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property real usedPercent: 0
    property real usedGb: 0
    property real totalGb: 0

    FileView {
        id: meminfo

        path: "/proc/meminfo"
        blockLoading: true
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            meminfo.reload();
            const text = meminfo.text();
            const total = parseInt(text.match(/MemTotal:\s+(\d+)/)[1]);
            const avail = parseInt(text.match(/MemAvailable:\s+(\d+)/)[1]);
            root.totalGb = total / 1.04858e+06;
            root.usedGb = (total - avail) / 1.04858e+06;
            root.usedPercent = (total - avail) / total * 100;
        }
    }

}
