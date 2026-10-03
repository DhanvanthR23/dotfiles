pragma Singleton
import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root

    readonly property var devices: Networking.devices.values

    // wifi devices expose `networks`, wired ones don't
    readonly property var wifiDevice: devices.find(d => d.networks !== undefined) || null
    readonly property var wiredDevice:
        devices.find(d => d.networks === undefined && d.connected && d.name !== "lo") || null

    readonly property var activeNetwork:
        wifiDevice ? (wifiDevice.networks.values.find(n => n.connected) || null) : null

    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property real signal: activeNetwork ? activeNetwork.signalStrength : 0

    // "wifi" | "wired" | "off" | "none"
    readonly property string type:
        wiredDevice ? "wired"
        : !wifiOn ? "off"
        : activeNetwork ? "wifi"
        : "none"

    readonly property string label:
        type === "wired" ? "Wired"
        : type === "off" ? "Off"
        : type === "wifi" ? activeNetwork.name
        : "Not connected"

    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
    readonly property string icon:
        type === "wired" ? "󰈀"
        : type === "off" ? "󰤮"
        : type === "none" ? "󰤭"
        : wifiIcons[Math.max(0, Math.min(4, Math.round(signal * 4)))]

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled
    }
}
