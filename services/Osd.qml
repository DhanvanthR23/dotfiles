import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    function showVolume() {
        const pct = Math.round(Audio.volume * 100);
        Notifs.show("Volume", Audio.muted ? "Volume muted" : "Volume · " + pct + "%", "", 1, 1200, Audio.muted ? 0 : Audio.volume);
    }

    function showBrightness() {
        Brightness.refreshInternal();
        const lv = Brightness.levels[Brightness.internalName];
        if (!lv)
            return;
        const f = lv.raw / lv.max;
        Notifs.show("Brightness", "Brightness · " + Math.round(f * 100) + "%", "", 1, 1200, f);
    }

    function showLock(kind) {
        if (lockReader.running)
            return;
        lockReader.label = kind === "capslock" ? "Caps Lock" : "Num Lock";
        lockReader.command = ["sh", "-c", "cat /sys/class/leds/*::" + kind + "/brightness 2>/dev/null | sort -r | head -n1"];
        lockReader.running = true;
    }

    // the LED flips a moment after the keypress
    Timer {
        id: lockDelay

        property string kind

        interval: 200
        onTriggered: root.showLock(kind)
    }

    Process {
        id: lockReader

        property string label

        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim();
                if (t === "")
                    return;
                Notifs.show(lockReader.label, lockReader.label + (t === "1" ? " on" : " off"), "", 1, 1200);
            }
        }
    }

    // PipeWire reports the new volume a moment after wpctl returns
    Timer {
        id: volumeDelay

        interval: 60
        onTriggered: root.showVolume()
    }

    function volume() {
        volumeDelay.restart();
    }

    function brightness() {
        showBrightness();
    }

    function lock(kind) {
        lockDelay.kind = kind;
        lockDelay.restart();
    }
}
