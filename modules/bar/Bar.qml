import Quickshell
import QtQuick
import "../../config"
import "../../services"

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors{
                top: true
                left: true
                right: true
            }

            color: "transparent"
            implicitHeight: Theme.barHeight

            margins {
                top: Theme.gap
                left: Theme.gap
                right: Theme.gap
            }

            ClockPill {
                anchors.centerIn: parent
            }

            Workspaces {
                screenName: modelData.name
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: Theme.padding
                }
            }
            Row {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: Theme.padding
                }
                spacing: Theme.gap

                StatPill { icon: "󰻠"; value: Cpu.usage.toFixed(0) + "%" ; valueColor: Cpu.usage > 80 ? Theme.warn : Theme.text}
                StatPill { icon: "󰍛"; value: Ram.usedGb.toFixed(1) + "G"; valueColor: Ram.usedPercent > 85 ? Theme.warn: Theme.text }
                StatPill { visible: Battery.available; icon: Battery.icon; value: Math.round(Battery.percent) + "%"}
            }
        }
    }
}
