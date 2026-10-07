import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton
import "../config"

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string scripts: home + "/.config/niri/scripts"
    readonly property string themeDir: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/colors/themes"
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/qs-test"
    property var themes: [] // [{ slug, name, swatches: [hex x5] }]
    property var wallpapers: [] // [{ path, thumb }]
    property bool loadingWalls: false
    property bool wallsDirty: false
    property string current: ""
    property string currentWall: ""

    function pretty(slug) {
        return slug.split("-").map((w) => {
            return w.charAt(0).toUpperCase() + w.slice(1);
        }).join(" ");
    }

    function readState(file) {
        try {
            file.reload();
            return file.text().trim();
        } catch (e) {
            return "";
        }
    }

    // called when the picker opens
    function refresh() {
        current = readState(themeFile);
        currentWall = readState(wallFile);
        if (!lister.running)
            lister.running = true;
        loadWallpapers();
    }

    function loadWallpapers() {
        if (current === "") {
            wallpapers = [];
            return ;
        }
        if (walls.running) {
            wallsDirty = true;
            return ;
        }
        loadingWalls = true;
        walls.command = [scripts + "/wall-list.fish", current];
        walls.running = true;
    }

    property string queued: ""

    function apply(slug) {
        current = slug;
        loadWallpapers();
        if (setter.running) {
            queued = slug; // rapid switching: run the latest one after this finishes
            return ;
        }
        setter.command = [scripts + "/set-theme.fish", slug];
        setter.running = true;
    }

    Process {
        id: setter

        onRunningChanged: {
            if (running)
                return ;
            Theme.reload();
            root.currentWall = root.readState(wallFile);
            if (root.queued !== "") {
                const s = root.queued;
                root.queued = "";
                root.apply(s);
            }
        }
    }

    function setWallpaper(path) {
        currentWall = path;
        Quickshell.execDetached(["awww", "img", path, "--transition-type", "fade", "--transition-duration", "1"]);
        wallFile.setText(path + "\n");
    }

    FileView {
        id: themeFile

        path: root.stateDir + "/theme"
        blockLoading: true
        printErrors: false
    }

    FileView {
        id: wallFile

        path: root.stateDir + "/wallpaper"
        blockLoading: true
        printErrors: false
    }

    // set-theme.fish picks a random wallpaper, read it back once it's done
    Timer {
        id: settle

        interval: 1500
        onTriggered: root.currentWall = root.readState(wallFile)
    }

    // one rg call over all theme files -> name + 5 swatch colors each
    Process {
        id: lister

        command: ["rg", "--no-heading", "--no-line-number", "--sort", "path", "^COLOR_(BG|IRIS|FOAM|GOLD|RED)=", root.themeDir]

        stdout: StdioCollector {
            onStreamFinished: {
                const order = [];
                const by = {
                };
                for (const line of this.text.split("\n")) {
                    const m = line.match(/([^\/]+)\.conf:COLOR_([A-Z]+)=([0-9a-fA-F]{6})/);
                    if (!m)
                        continue;
                    if (!by[m[1]]) {
                        by[m[1]] = {
                        };
                        order.push(m[1]);
                    }
                    by[m[1]][m[2]] = "#" + m[3];
                }
                root.themes = order.map((s) => {
                    return {
                        "slug": s,
                        "name": root.pretty(s),
                        "swatches": ["BG", "IRIS", "FOAM", "GOLD", "RED"].map((k) => {
                            return by[s][k] || "#000000";
                        })
                    };
                });
            }
        }

    }

    Process {
        id: walls

        onRunningChanged: {
            if (!running && root.wallsDirty) {
                root.wallsDirty = false;
                root.loadWallpapers();
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of this.text.split("\n")) {
                    const p = line.split("\t");
                    if (p.length === 2)
                        out.push({
                            "path": p[0],
                            "thumb": p[1]
                        });

                }
                root.wallpapers = out;
                root.loadingWalls = false;
            }
        }

    }

}
