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

    // entry id -> { n: launch count, t: last launch ms }
    property var launches: ({})
    readonly property string storeDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/qs-test"

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

    // 3 = name starts with, 2 = name contains, 1 = generic name / keywords contain

    function activate(item) {
        if (item.kind === "app") {
            bump(item.entry.id);
            if (item.entry.runInTerminal)
                Quickshell.execDetached([Settings.terminal, "-e"].concat(Array.from(item.entry.command)));
            else
                item.entry.execute();
        } else if (item.kind === "calc") {
            Quickshell.execDetached(["wl-copy", item.title]);
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
