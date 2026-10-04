import QtQuick
import Quickshell
pragma Singleton

Singleton {
    // press feedback

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
}
