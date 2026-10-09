import QtQuick
import Quickshell
pragma Singleton

Singleton {
    readonly property int nightTemperature: 4000
    readonly property string latitude: "11.0"
    readonly property string longitude: "77.0"
    readonly property int idleScreenOff: 300 // seconds
    readonly property int idleLock: 600
    readonly property string terminal: "foot"
}
