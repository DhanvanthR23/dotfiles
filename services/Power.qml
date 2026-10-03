pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile
    readonly property int profile: PowerProfiles.profile

    readonly property string label:
        profile === PowerProfile.PowerSaver ? "power-saver"
        : profile === PowerProfile.Performance ? "performance"
        : "balanced"
    readonly property bool balanced: profile === PowerProfile.Balanced
    readonly property string icon:
        profile === PowerProfile.PowerSaver ? "󰌪"
        : profile === PowerProfile.Performance ? "󱐋"
        : "󰾅"

    function cycle() {
        const order = hasPerformance
            ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
            : [PowerProfile.PowerSaver, PowerProfile.Balanced]
        const i = order.indexOf(profile)
        PowerProfiles.profile = order[(i + 1) % order.length]
    }
}
