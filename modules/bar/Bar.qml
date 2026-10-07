import "../../components"
import "../../config"
import "../../services"
import "../calendar"
import "../control"
import "../launcher"
import "../picker"
import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            // qmllint enable unqualified

            id: bar

            required property var modelData

            screen: modelData
            color: "transparent"
            implicitHeight: Theme.barHeight

            anchors {
                top: true
                left: true
                right: true
            }

            ControlPopup {
                id: controlPopup

                pill: controlPill
            }

            LauncherPopup {
                id: launcherPopup

                screen: bar.modelData
                pill: launcherPill
            }

            PickerPopup { screen: bar.modelData }

            IdleInhibitor {
                window: bar
                enabled: Idle.inhibited
            }

            // qmllint disable unqualified
            margins {
                top: Theme.gap
                left: Theme.gap
                right: Theme.gap
            }
            // qmllint enable unqualified

            ClockPill {
                id: clockPill
                launcherExpand: launcherPopup.fade
                opacity: launcherPopup.progress > 0.02 ? 0 : 1
                anchors.centerIn: parent
                expand: calendarPopup.progress
                onPickerRequested: Picker.toggle(bar.modelData.name)
            }

            CalendarPopup {
                id: calendarPopup

                pill: clockPill
            }

            Row {
                spacing: 0

                anchors {
                    right: clockPill.left
                    rightMargin: Theme.gap
                    verticalCenter: parent.verticalCenter
                }

                Item {
                    id: launcherSlot

                    width: (Theme.pillHeight + Theme.gap) * (1 - launcherPopup.travel)
                    height: Theme.pillHeight

                    LauncherPill {
                        id: launcherPill

                        opacity: launcherPopup.progress > 0.02 ? 0 : 1
                        onClicked: launcherPopup.toggle()
                    }
                }

                Workspaces {
                    screenName: bar.modelData.name
                }
            }


            Row {
                spacing: Theme.gap

                anchors {
                    left: clockPill.right
                    leftMargin: Theme.gap
                    verticalCenter: parent.verticalCenter
                }

                SystemPill { id: systemPill }


                ControlPill {
                    id: controlPill

                    tipEnabled: !controlPopup.open
                    opacity: controlPopup.progress > 0.2 ? 0 : 1
                    onClicked: controlPopup.toggle()
                }

                LazyLoader {
                    active: controlPopup.open

                    ControlBackdrop {
                        screen: bar.modelData
                        onDismissed: controlPopup.close()
                    }
                }

            }

        }

    }

}
