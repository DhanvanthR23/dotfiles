import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property real usage: 0
    property real prevIdle: 0
    property real prevTotal: 0

    FileView {
        id: stat

        path: "/proc/stat"
        blockLoading: true
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            const line = stat.text().split("\n")[0];
            const values = line.trim().split(/\s+/).slice(1).map(Number);
            const currentIdle = values[3] + values[4];
            const currentTotal = values.reduce((a, b) => {
                return a + b;
            }, 0);
            if (root.prevTotal > 0) {
                const idleDelta = currentIdle - root.prevIdle;
                const totalDelta = currentTotal - root.prevTotal;
                if (totalDelta > 0)
                    root.usage = (1 - (idleDelta / totalDelta)) * 100;

            }
            root.prevIdle = currentIdle;
            root.prevTotal = currentTotal;
        }
    }

}
