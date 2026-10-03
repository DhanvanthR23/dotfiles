import Quickshell
import QtQuick
import "../../config"
import "../../services"

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
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
                id: clock
                anchors.centerIn: parent
                expand: popup.progress
            }

            CalendarPopup { id: popup; pill: clock }

            Row {
                anchors {
                    right: clock.left
                    rightMargin: Theme.gap
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.gap

                Workspaces {
                    screenName: bar.modelData.name
                }
            }

            Row {
                anchors {
                    left: clock.right
                    leftMargin: Theme.gap
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.gap

                StatPill { icon: "󰻠"; value: Cpu.usage.toFixed(0) + "%"; valueColor: Cpu.usage > 80 ? Theme.warn : Theme.text }
                StatPill { icon: "󰍛"; value: Ram.usedGb.toFixed(1) + "G"; valueColor: Ram.usedPercent > 85 ? Theme.warn : Theme.text }
                StatPill { visible: Battery.available; icon: Battery.icon; value: Math.round(Battery.percent) + "%"; valueColor: Battery.low ? Theme.error : Theme.text }
                StatPill {
                    visible: Updates.count > 0
                    icon: "󰚰"
                    value: String(Updates.count)
                    valueColor: Updates.count >= 50 ? Theme.error : Updates.count >= 25 ? Theme.warn : Theme.text
                }
            }
        }
    }
}
