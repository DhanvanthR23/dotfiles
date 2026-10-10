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

    // same exponential curve as the control center slider, so both show the same number
    // read sysfs fresh through a process: FileView.reload() + text() can return the previous value
    function showBrightness() {
        if (Brightness.internalName === "" || brightnessReader.running)
            return;
        const dir = "/sys/class/backlight/" + Brightness.panel;
        brightnessReader.command = ["sh", "-c", "cat " + dir + "/brightness " + dir + "/max_brightness"];
        brightnessReader.running = true;
    }

    Process {
        id: brightnessReader

        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim().split(/\s+/).map(Number);
                if (t.length < 2 || !(t[1] > 0))
                    return;
                Brightness.setLevel(Brightness.internalName, t[0], t[1]); // keep the slider in sync
                const pos = t[0] / t[1];
                Notifs.show("Brightness", "Brightness · " + Math.round(pos * 100) + "%", "", 1, 1200, pos);
            }
        }
    }

    function showLock(kind) {
        if (lockReader.running)
            return;
        lockReader.label = kind === "capslock" ? "Caps Lock" : "Num Lock";
        // glob over every keyboard LED, so the input<N> name doesn't matter
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
