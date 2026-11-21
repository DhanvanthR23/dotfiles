import "calc.js" as CalcJs
import "../config"
import "search.js" as SearchJs
import Quickshell.Io
import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    readonly property int maxResults: 8
    property string query: ""
    readonly property string needle: query.trim().toLowerCase()
    readonly property var apps: DesktopEntries.applications.values.filter((e) => {
        return !e.noDisplay;
    })
    // only try the calculator when there is a binary operator, so "5" or "-5" don't spawn a row
    readonly property string calcResult: {
        if (!/[\d)]\s*[-+*\/%^]/.test(query))
            return "";

        const v = CalcJs.evaluate(query);
        return v === null ? "" : String(Number(v.toPrecision(12))); // trims 0.1+0.2 noise
    }
    property int selected: 0
    readonly property bool fileMode: query.startsWith("f ")
    readonly property string fileNeedle: fileMode ? query.slice(2).trim() : ""
    readonly property string home: Quickshell.env("HOME")
    property var fileHits: []

    onFileNeedleChanged: fileDebounce.restart()
    onFileHitsChanged: selected = 0

    Timer {
        id: fileDebounce
        interval: 120
        onTriggered: root.runFileSearch()
    }

    function runFileSearch() {
        if (fileNeedle.length < 2) {
            fileHits = [];
            return;
        }
        if (fileProc.running) {
            fileProc.running = false; // onRunningChanged restarts with the newest needle
            return;
        }
        fileProc.needle = fileNeedle;
        fileProc.command = ["fd", "--type", "f", "--ignore-case", "--max-results", "8",
                            "--color", "never", "--", fileNeedle, home];
        fileProc.running = true;
    }

    Process {
        id: fileProc
        property string needle

        onRunningChanged: {
            if (!running && root.fileMode && needle !== root.fileNeedle)
                root.runFileSearch();
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (fileProc.needle !== root.fileNeedle)
                    return; // stale result
                root.fileHits = this.text.split("\n").filter((l) => l !== "");
            }
        }
    }

    // entry id -> { n: launch count, t: last launch ms }
    property var launches: ({})
    readonly property string storeDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/qs-test"

    property string qalcResult: ""
    readonly property bool qalcMode: query.startsWith("=")
    readonly property string qalcExpr: query.slice(1).trim()

    readonly property bool cmdMode: query.startsWith(">")
    readonly property string cmdNeedle: query.slice(1).trim().toLowerCase()
    readonly property var commands: [
        { "label": "Themes", "sub": "Theme picker", "run": () => Picker.show("") },
        { "label": "Wallpapers", "sub": "Wallpaper picker", "run": () => { Picker.view = "walls"; Picker.show(""); } },
        { "label": "Clipboard", "sub": "History", "run": () => Clip.show("") },
        { "label": "Session", "sub": "Lock, logout, power", "run": () => Session.show("") },
        { "label": "Lock", "sub": "Lock screen", "run": () => Quickshell.execDetached([Idle.lockScript]) },
        { "label": "Check updates", "sub": "Refresh count", "run": () => Updates.check(true) },
        { "label": "Run updates", "sub": "paru -Syu", "run": () => Updates.run() },
        { "label": "Keep awake", "sub": "Toggle", "run": () => Idle.toggle() },
        { "label": "Do not disturb", "sub": "Toggle", "run": () => { Notifs.dnd = !Notifs.dnd; } },
        { "label": "Game mode", "sub": "Toggle", "run": () => { GameMode.active = !GameMode.active; } },
        { "label": "Night light", "sub": "Cycle off / now / auto", "run": () => NightLight.cycle() },
        { "label": "Power profile", "sub": "Cycle", "run": () => Power.cycle() },
        { "label": "Clear notifications", "sub": "Dismiss all", "run": () => Notifs.clearAll() }
    ]

    onQalcExprChanged: {
        qalcResult = "";
        if (qalcMode && qalcExpr !== "")
            qalcDebounce.restart();
        else
            qalcDebounce.stop();
    }

    Timer {
        id: qalcDebounce
        interval: 250
        onTriggered: {
            qalcProc.command = ["qalc", "-t", root.qalcExpr];
            qalcProc.running = true;
        }
    }

    Process {
        id: qalcProc
        stdout: StdioCollector {
            onStreamFinished: root.qalcResult = this.text.trim()
        }
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", storeDir]);
        try {
            launches = JSON.parse(store.text());
        } catch (e) {
            // no history yet
        }
    }

    FileView {
        id: store

        path: root.storeDir + "/launches.json"
        blockLoading: true
        printErrors: false
    }

    onQueryChanged: selected = 0

    function move(delta) {
        const n = results.length;
        if (n > 0)
            selected = (selected + delta + n) % n;
    }

    // returns true if something was activated
    function activateSelected() {
        const r = results[selected];
        if (!r)
            return false;
        activate(r);
        return true;
    }

    // [{ kind: "calc" | "app", title, subtitle, entry? }]
    readonly property var results: {
        const out = [];
        if (fileMode) {
            return fileHits.map((p) => {
                const i = p.lastIndexOf("/");
                return {
                    "kind": "file",
                    "title": p.slice(i + 1),
                    "subtitle": p.slice(0, i).replace(home, "~"),
                    "path": p
                };
            });
        }
        if (qalcMode) {
                return qalcResult !== ""
                    ? [{ "kind": "calc", "title": qalcResult, "subtitle": "Copy result" }]
                    : [];
            }

        if (cmdMode) {
            return commands
                .filter((c) => cmdNeedle === "" || SearchJs.tier(cmdNeedle, c.label, c.sub) > 0)
                .map((c) => ({ "kind": "cmd", "title": c.label, "subtitle": c.sub, "run": c.run }));
        }

        if (calcResult !== "")
            out.push({
            "kind": "calc",
            "title": calcResult,
            "subtitle": "Copy result"
        });

        const scored = [];
        for (const e of apps) {
            const t = needle === "" ? 1 : SearchJs.tier(needle, e.name, e.genericName + " " + e.keywords.join(" "));
            if (t > 0)
                scored.push({
                    "t": t,
                    "b": boost(e.id),
                    "e": e
                });
        }
        scored.sort((a, b) => {
            return b.t - a.t || b.b - a.b || a.e.name.localeCompare(b.e.name);
        });
        for (const x of scored.slice(0, maxResults)) out.push({
            "kind": "app",
            "title": x.e.name,
            "subtitle": x.e.genericName || x.e.comment,
            "entry": x.e
        })
        return out;
    }

    function activate(item) {
        if (item.kind === "app") {
            bump(item.entry.id);
            if (item.entry.runInTerminal)
                Quickshell.execDetached([Settings.terminal, "-e"].concat(Array.from(item.entry.command)));
            else
                item.entry.execute();
        } else if (item.kind === "calc") {
            Quickshell.execDetached(["wl-copy", item.title]);
        } else if (item.kind === "cmd") {
            item.run();
        } else if (item.kind === "file") {
            Quickshell.execDetached(["xdg-open", item.path]);
        }
    }

    function reset() {
        query = "";
        selected = 0;
    }
    // more launches + more recent = bigger; fades with a ~30 day scale
    function boost(id) {
        const l = launches[id];
        if (!l)
            return 0;
        const ageDays = (Date.now() - l.t) / 86400000;
        return Math.log(1 + l.n) / (1 + ageDays / 30);
    }

    function bump(id) {
        const next = Object.assign({}, launches);
        next[id] = {
            "n": (next[id] ? next[id].n : 0) + 1,
            "t": Date.now()
        };
        launches = next; // replace, don't mutate
        store.setText(JSON.stringify(next));
    }

}
