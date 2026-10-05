import "../../components"
import "../../config"
import "../../services"
import QtQuick

Pill {
    id: root

    implicitWidth: row.implicitWidth + 20

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 8

        StatItem {
            icon: "󰻠"
            value: Cpu.usage.toFixed(0) + "%"
            valueColor: Cpu.usage > 80 ? Theme.warn : Theme.text
            sample: "99%"
            spacing: 4
        }

        StatItem {
            icon: "󰍛"
            value: Ram.usedGb.toFixed(1) + "G"
            valueColor: Ram.usedPercent > 85 ? Theme.warn : Theme.text
            sample: "0.0G"
            spacing: 4
        }
    }
}
