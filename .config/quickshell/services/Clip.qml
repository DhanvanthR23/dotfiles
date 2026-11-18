import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    readonly property int maxResults: 8
    property bool open: false
    property bool loading: false
    property string screenName: ""
    property string query: ""
    property int selected: 0
    property var entries: [] // [{ raw, text }], only filled while the card is open
    readonly property string needle: query.trim().toLowerCase()
    readonly property var results: {
        const out = [];
        for (const e of entries) {
            if (needle === "" || e.text.toLowerCase().includes(needle)) {
                out.push(e);
                if (out.length >= maxResults)
                    break;
            }
        }
        return out;
    }

    readonly property string thumbDir: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/qs-clip"
    property var thumbReady: ({})   // id -> true once the file exists
    property var thumbBatch: []
    property bool thumbPending: false

    function isImage(e) { return e.text.startsWith("[[ binary data"); }
    function idOf(e) { return e.raw.split("\t")[0]; }

    function requestThumbs() {
        const batch = results.filter((e) => isImage(e) && !thumbReady[idOf(e)]);
        if (batch.length === 0)
            return;
        if (thumber.running) {
            thumbPending = true;
            return;
        }
        thumbBatch = batch;
        const script = 'd="$1"; shift; mkdir -p "$d"; for raw; do id=$(printf "%s" "$raw" | cut -f1); '
            + '[ -f "$d/$id.png" ] || printf "%s\\n" "$raw" | cliphist decode | magick - -thumbnail 320x180 "png:$d/$id.png"; done';
        thumber.command = ["sh", "-c", script, "_", thumbDir].concat(batch.map((e) => e.raw));
        thumber.running = true;
    }

    Process {
        id: thumber

        onRunningChanged: {
            if (running)
                return;
            const next = Object.assign({}, root.thumbReady);
            for (const e of root.thumbBatch) next[root.idOf(e)] = true;
            root.thumbReady = next; // replace, don't mutate
            if (root.thumbPending) {
                root.thumbPending = false;
                root.requestThumbs();
            }
        }
    }

    function load() {
        if (!lister.running)
            lister.running = true;
    }

    function show(name) {
        screenName = name || Picker.focusedOutput();
        loading = true;
        load();
        open = true;
    }

    function hide() {
        open = false;
        query = "";
        selected = 0;
        entries = []; // free the history while closed
        thumbReady = ({});
        Quickshell.execDetached(["rm", "-rf", thumbDir]);
    }

    function toggle(name) {
        if (open)
            hide();
        else
            show(name);
    }

    function move(delta) {
        const n = results.length;
        if (n > 0)
            selected = (selected + delta + n) % n;
    }

    // returns true if something was copied
    function activateSelected() {
        const r = results[selected];
        if (!r)
            return false;
        hide();
        Quickshell.execDetached(["sh", "-c", "printf '%s\\n' \"$1\" | cliphist decode | wl-copy", "_", r.raw]);
        return true;
    }

    function deleteSelected() {
        const r = results[selected];
        if (!r || deleter.running)
            return;
        deleter.command = ["sh", "-c", "printf '%s\\n' \"$1\" | cliphist delete", "_", r.raw];
        deleter.running = true;
    }

    onQueryChanged: selected = 0
    onResultsChanged: {
        if (selected >= results.length)
            selected = Math.max(0, results.length - 1);
        requestThumbs();
    }

    Process {
        id: lister

        command: ["cliphist", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of this.text.split("\n")) {
                    const i = line.indexOf("\t");
                    if (i < 0)
                        continue;
                    out.push({
                        "raw": line,
                        "text": line.slice(i + 1).replace(/\s+/g, " ").trim()
                    });
                }
                if (root.open)
                    root.entries = out;
                root.loading = false;
            }
        }
    }

    Process {
        id: deleter

        onRunningChanged: {
            if (!running && root.open)
                root.load();
        }
    }

}
