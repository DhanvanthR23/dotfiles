import QtQuick
import Quickshell
import Quickshell.Services.UPower
pragma Singleton

Singleton {
    id: root

    readonly property var levelIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargingIcons: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property var device: UPower.displayDevice
    readonly property bool available: device.ready && device.isPresent
    readonly property real percent: device.percentage * 100
    readonly property bool pluggedIn: !UPower.onBattery
    readonly property bool charging: device.state === UPowerDeviceState.Charging
    readonly property bool low: available && UPower.onBattery && percent <= 20
    readonly property int level: Math.max(0, Math.min(10, Math.round(percent / 10)))
    readonly property string icon: low ? "󰂃" : charging ? chargingIcons[level] : levelIcons[level]

    property int warnedAt: 100 // lowest threshold already warned about

    function check() {
        if (!available)
            return;
        if (pluggedIn) {
            warnedAt = 100; // re-arm once plugged in
            return;
        }
        for (const t of [10, 20]) {
            if (percent <= t && warnedAt > t) {
                warnedAt = t;
                Notifs.show("Battery", t + "% battery", "Plug in soon", t <= 10 ? 2 : 1, -1);
                return;
            }
        }
    }

    onPercentChanged: check()
    onPluggedInChanged: check()
    onAvailableChanged: check()
}
