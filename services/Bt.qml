import QtQuick
import Quickshell
import Quickshell.Bluetooth
pragma Singleton

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    // devices that are currently connected (re-evaluates when any device's state changes)
    readonly property var connected: Bluetooth.devices.values.filter((d) => {
        return d.connected;
    })
    readonly property int connectedCount: connected.length
    // short text for a tile subtitle
    readonly property string label: !available ? "No adapter" : !enabled ? "Off" : connectedCount === 0 ? "On" : connectedCount === 1 ? connected[0].name : connectedCount + " devices"

    function toggle() {
        if (adapter)
            adapter.enabled = !adapter.enabled;

    }

}
