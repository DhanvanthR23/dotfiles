// config/Theme.qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // surfaces
    readonly property color bg: "#191724"
    readonly property color surface: "#1f1d2e"
    readonly property color surfaceAlt: "#26233a"
    readonly property color border: "#403d52"

    // text
    readonly property color text: "#e0def4"
    readonly property color textMuted: "#908caa"

    // accents
    readonly property color accent: "#c4a7e7"
    readonly property color ok: "#9ccfd8"
    readonly property color warn: "#f6c177"
    readonly property color error: "#eb6f92"

    // sizes
    readonly property int radius: 16
    readonly property int gap: 10
    readonly property int padding: 12

    // font
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property string fontFamily: "Google Sans Flex"
    readonly property int fontSize: 14

    readonly property int barHeight: 40
    readonly property int pillHeight: 28
    readonly property int toastWidth: 340
    readonly property int toastHeight: 40
    readonly property int animDuration: 180
}
