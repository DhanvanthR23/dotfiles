import QtQuick
import Quickshell
pragma Singleton
import Quickshell.Io

Singleton {
    id: root

    // surfaces
    property color bg: "#191724"
    property color surface: "#1f1d2e"
    property color surfaceAlt: "#26233a"
    property color border: "#403d52"
    // text
    property color text: "#e0def4"
    property color textMuted: "#908caa"
    // accents
    property color accent: "#c4a7e7"
    property color ok: "#9ccfd8"
    property color warn: "#f6c177"
    property color error: "#eb6f92"

    readonly property string confPath: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/colors/colors.conf"

    function reload() {
        conf.reload();
        applyConf();
    }

    function applyConf() {
        const m = {};
        for (const line of conf.text().split("\n")) {
            const x = line.match(/^COLOR_([A-Z_]+)=([0-9a-fA-F]{6})/);
            if (x)
                m[x[1]] = "#" + x[2];
        }
        if (m.BG) bg = m.BG;
        if (m.SURFACE) surface = m.SURFACE;
        if (m.OVERLAY) surfaceAlt = m.OVERLAY;
        if (m.BORDER) border = m.BORDER;
        if (m.FG) text = m.FG;
        if (m.FG_SUBTLE) textMuted = m.FG_SUBTLE;
        if (m.IRIS) accent = m.IRIS;
        if (m.FOAM) ok = m.FOAM;
        if (m.GOLD) warn = m.GOLD;
        if (m.RED) error = m.RED;
    }

    Component.onCompleted: applyConf()

    FileView {
        id: conf

        path: root.confPath
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: {
            reload();
            root.applyConf();
        }
    }

        IpcHandler {
            target: "theme"

            function reload(): void {
                root.reload();
            }
        }

    // font
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property string fontFamily: "Google Sans Flex"
    readonly property int fontSize: 14
    readonly property int barHeight: 40
    readonly property int pillHeight: 28
    readonly property int toastWidth: 340
    readonly property int toastHeight: 40
    readonly property int animDuration: 180
    // sizes
    readonly property int radius: 16
    // cards
    readonly property int radiusItem: 14
    // tiles, notification rows, calendar cells
    readonly property int radiusSmall: 10
    // list items inside a card (monitor picker)
    readonly property int gap: 10
    readonly property int padding: 12
    readonly property int popupWidth: 340
    // type
    readonly property int fontSmall: fontSize - 1
    readonly property int fontCaption: fontSize - 3
    readonly property int iconSize: fontSize + 4
    readonly property int iconSizeLarge: fontSize + 6
    // motion
    readonly property int animFast: 120
    // hover/color/opacity
    readonly property int animPress: 80

    readonly property int launcherWidth: 480
    readonly property int animLauncher: 340
    readonly property int animLauncherClose: 520

    readonly property int sessionWidth: 260
}
