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
            ControlPopup { id: controlPopup; pill: controlPill }
            ControlBackdrop { popup: controlPopup; screen: bar.modelData }

            // qmllint disable unqualified
            margins {
                top: Theme.gap
                left: Theme.gap
                right: Theme.gap
            }
            // qmllint enable unqualified

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

                StatPill { icon: "󰻠"; value: Cpu.usage.toFixed(0) + "%"; valueColor: Cpu.usage > 80 ? Theme.warn : Theme.text ; sample: "99%"}
                StatPill { icon: "󰍛"; value: Ram.usedGb.toFixed(1) + "G"; valueColor: Ram.usedPercent > 85 ? Theme.warn : Theme.text ; sample: "0.0G"}
                StatPill {
                    visible: Updates.count > 0
                    icon: "󰚰"
                    value: String(Updates.count)
                    valueColor: Updates.count >= 50 ? Theme.error : Updates.count >= 25 ? Theme.warn : Theme.text
                    sample: "999"
                }
                ControlPill {
                    id: controlPill
                    tipEnabled: !controlPopup.open
                    opacity: controlPopup.progress > 0.2 ? 0 : 1
                    onClicked: controlPopup.toggle()
                }
            }
        }
    }
}
