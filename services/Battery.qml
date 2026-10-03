pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton{
    id: root
    readonly property var levelIcons:    ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargingIcons: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property var device: UPower.displayDevice
    readonly property bool available: device.ready && device.isPresent
    readonly property real percent: device.percentage * 100
    readonly property bool pluggedIn: !UPower.onBattery
    readonly property bool charging: device.state === UPowerDeviceState.Charging
    readonly property bool low: available && UPower.onBattery && percent <= 20
    readonly property int level: Math.max(0, Math.min(10, Math.round(percent / 10)))
    readonly property string icon: low ? "󰂃"
                                 : charging ? chargingIcons[level]
                                 : levelIcons[level]
}
