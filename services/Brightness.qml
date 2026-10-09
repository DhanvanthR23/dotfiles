import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    readonly property string panel: "intel_backlight"
    // --- which monitor the slider controls ---
    property string selected: ""
    readonly property var names: Quickshell.screens.map((s) => {
        return s.name;
    })
    readonly property string current: names.includes(selected) ? selected : (names.find(isInternal) || names[0] || "")
    readonly property string internalName: names.find(isInternal) || ""
    // --- levels: screen name -> { raw, max } ---
    property var levels: ({
    })
    property bool watching: false
    readonly property var level: levels[current] || null
    readonly property bool controllable: level !== null
    readonly property real position: level ? toPosition(level.raw / level.max, floorFor(current)) : 0
    // --- external monitors: connector name -> ddcutil display number ---
    property var ddcDisplays: ({
    })
    // --- writing: only the latest wanted value waits in line ---
    property var pending: null
    // { name, value }
    readonly property bool writing: setter.running || pending !== null

    function isInternal(n) {
        return n.startsWith("eDP") || n.startsWith("LVDS") || n.startsWith("DSI");
    }

    function setLevel(name, raw, max) {
        const old = levels[name];
        if (old && old.raw === raw && old.max === max)
            return ;

        // avoid pointless rebinding
        const next = Object.assign({
        }, levels);
        next[name] = {
            "raw": raw,
            "max": max
        };
        levels = next; // must replace, not mutate
    }

    // --- exponential curve: slider position <-> fraction of max ---
    function floorFor(name) {
        return isInternal(name) ? 0.01 : 0.05;
    }

    function toFraction(p, floor) {
        return floor * Math.pow(1 / floor, p);
    }

    function toPosition(f, floor) {
        return Math.log(Math.max(f, floor) / floor) / Math.log(1 / floor);
    }

    function refreshInternal() {
        if (internalName === "" || writing)
            return ;

        rawFile.reload();
        maxFile.reload();
        setLevel(internalName, parseInt(rawFile.text()) || 0, parseInt(maxFile.text()) || 1);
    }

    function runDetect() {
        if (detector.running)
            return ;

        if (!names.some((n) => {
            return !isInternal(n);
        })) {
            ddcDisplays = {
            };
            return ;
        }
        detector.running = true;
    }

    function readExternal(name) {
        const n = ddcDisplays[name];
        if (!n || reader.running || writing)
            return ;

        reader.target = name;
        reader.command = ["ddcutil", "getvcp", "10", "--brief", "--display", String(n)];
        reader.running = true;
    }

    // called when the popup opens, and when the selection changes
    function refresh() {
        refreshInternal();
        if (current !== "" && !isInternal(current))
            readExternal(current);

    }

    function flush() {
        if (setter.running || pending === null)
            return ;

        const job = pending;
        pending = null;
        if (isInternal(job.name))
            setter.command = ["brightnessctl", "-q", "-d", panel, "set", String(job.value)];
        else
            setter.command = ["ddcutil", "setvcp", "10", String(job.value), "--noverify", "--display", String(ddcDisplays[job.name])];
        setter.running = true;
    }

    function setPosition(p) {
        const name = current;
        const lv = levels[name];
        if (!lv)
            return ;

        const frac = toFraction(Math.max(0, Math.min(1, p)), floorFor(name));
        const raw = Math.round(lv.max * frac);
        const value = isInternal(name) ? Math.max(1, raw) : raw;
        setLevel(name, value, lv.max); // optimistic, so nothing snaps back
        pending = {
            "name": name,
            "value": value
        };
        flush();
    }

    onNamesChanged: detectTimer.restart()
    Component.onCompleted: runDetect()
    onCurrentChanged: refresh()

    Timer {
        interval: 1000
        running: root.watching
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshInternal()
    }

    // --- built-in panel: read from sysfs ---
    FileView {
        id: rawFile

        path: "/sys/class/backlight/" + root.panel + "/brightness"
        blockLoading: true
    }

    FileView {
        id: maxFile

        path: "/sys/class/backlight/" + root.panel + "/max_brightness"
        blockLoading: true
    }

    Process {
        id: detector

        command: ["ddcutil", "detect", "--brief"]

        stdout: StdioCollector {
            onStreamFinished: {
                const map = {
                };
                let display = 0;
                for (const line of this.text.split("\n")) {
                    const d = line.match(/^Display (\d+)/);
                    if (d) {
                        display = parseInt(d[1]);
                        continue;
                    }
                    if (/^(Invalid|Phantom|Disconnected)/.test(line)) {
                        display = 0;
                        continue;
                    }
                    const c = line.match(/DRM[_ ]connector:\s+card\d+-(\S+)/);
                    if (c && display > 0)
                        map[c[1]] = display;

                }
                root.ddcDisplays = map;
                root.refresh();
            }
        }

    }

    Timer {
        id: detectTimer

        interval: 2000
        onTriggered: root.runDetect()
    }

    // --- external monitors: read one on demand ---
    Process {
        id: reader

        property string target

        stdout: StdioCollector {
            onStreamFinished: {
                // brief format: "VCP 10 C <current> <max>"
                const t = this.text.trim().split(/\s+/);
                if (t[0] === "VCP" && t[2] === "C")
                    root.setLevel(reader.target, parseInt(t[3]), parseInt(t[4]));

            }
        }

    }

    Process {
        id: setter

        onRunningChanged: {
            if (!running)
                root.flush();

        }
    }

}
