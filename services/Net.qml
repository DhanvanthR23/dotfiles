import QtQuick
import Quickshell
import Quickshell.Networking
pragma Singleton
import "../config"

Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    // wifi devices expose `networks`, wired ones don't
    readonly property var wifiDevice: devices.find((d) => {
        return d.networks !== undefined;
    }) || null
    readonly property var wiredDevice: devices.find((d) => {
        return d.networks === undefined && d.connected && d.name !== "lo";
    }) || null
    readonly property var activeNetwork: wifiDevice ? (wifiDevice.networks.values.find((n) => {
        return n.connected;
    }) || null) : null
    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property real strength: activeNetwork ? activeNetwork.signalStrength : 0
    // "wifi" | "wired" | "off" | "none"
    readonly property string type: wiredDevice ? "wired" : !wifiOn ? "off" : activeNetwork ? "wifi" : "none"
    readonly property string label: type === "wired" ? "Wired" : type === "off" ? "Off" : type === "wifi" ? activeNetwork.name : "Not connected"
    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
    readonly property string icon: type === "wired" ? "󰈀" : type === "off" ? "󰤮" : type === "none" ? "󰤭" : wifiIcons[Math.max(0, Math.min(4, Math.round(strength * 4)))]

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }
    function openManager() {
        Quickshell.execDetached([Settings.terminal, "--app-id", "wlctl", "-e", "wlctl"]);
    }

}
