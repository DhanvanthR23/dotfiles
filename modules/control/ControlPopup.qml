import "../../components"
import "../../config"
import "../../services"
import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item pill
    readonly property int cardWidth: Theme.popupWidth
    readonly property int contentHeight: body.implicitHeight + Theme.padding * 2
    // --- open/close ---
    property bool open: false
    // pointer counts as "inside" on the pill or on the card
    readonly property bool inside: pill.hovered || popupHover.hovered
    // --- animation driver: 0 = pill, 1 = full card ---
    property real progress: open ? 1 : 0
    readonly property real fade: Math.max(0, progress * 2 - 1) // 0 in the first half, ramps to 1 in the second

    function toggle() {
        open = !open;
    }

    function close() {
        open = false;
    }

    onInsideChanged: {
        if (inside)
            leaveTimer.stop();
        else if (open)
            leaveTimer.restart();
    }
    onOpenChanged: {
        Brightness.watching = open;
        if (open)
            Brightness.refresh();
        else
            leaveTimer.stop();
    }
    // window's top-left corner sits on the pill's top-left corner
    anchor.item: pill
    anchor.rect.x: 0
    anchor.rect.y: 0
    implicitWidth: cardWidth
    implicitHeight: Theme.pillHeight + contentHeight
    visible: open || progress > 0
    color: "transparent"

    Timer {
        id: leaveTimer

        interval: 1000
        onTriggered: root.close()
    }

    Rectangle {
        id: card

        anchors.top: parent.top
        anchors.left: parent.left
        width: root.pill.width + (root.cardWidth - root.pill.width) * root.progress
        height: Theme.pillHeight + root.contentHeight * root.progress
        radius: Math.min(height / 2, Theme.radius)
        color: Theme.surface
        border.width: 1
        border.color: Theme.border
        clip: true

        // copy of the pill, same spot, so the handoff is invisible
        ControlPill {
            tipEnabled: false
            onClicked: root.close()
        }

        Text {
            x: Theme.pillHeight + 10
            height: Theme.pillHeight
            verticalAlignment: Text.AlignVCenter
            text: "Control center"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            opacity: root.fade
        }

        Item {
            y: Theme.pillHeight
            width: root.cardWidth
            height: root.contentHeight
            opacity: root.fade
            enabled: root.open

            Column {
                id: body

                x: Theme.padding
                y: Theme.padding
                width: parent.width - Theme.padding * 2
                spacing: Theme.gap

                Row {
                    width: parent.width
                    spacing: Theme.gap

                    Tile {
                        width: (parent.width - parent.spacing) / 2
                        icon: Net.icon
                        title: "Wi-Fi"
                        subtitle: Net.label
                        active: Net.wifiOn
                        onClicked: Net.toggleWifi()
                    }

                    Tile {
                        width: (parent.width - parent.spacing) / 2
                        icon: Bt.enabled ? "󰂯" : "󰂲"
                        title: "Bluetooth"
                        subtitle: Bt.label
                        active: Bt.enabled
                        onClicked: Bt.toggle()
                    }

                }

                Row {
                    width: parent.width
                    spacing: Theme.gap

                    Tile {
                        width: (parent.width - parent.spacing) / 2
                        icon: Power.icon
                        title: "Power"
                        subtitle: Power.label
                        active: !Power.balanced
                        onClicked: Power.cycle()
                    }

                    Tile {
                        width: (parent.width - parent.spacing) / 2
                        icon: NightLight.mode === "off" ? "󰖙" : "󰖔"
                        title: "Night light"
                        subtitle: NightLight.mode === "off" ? "Off" : NightLight.mode === "now" ? "On" : "Auto"
                        active: NightLight.enabled
                        onClicked: NightLight.cycle()
                    }

                }

                Row {
                    width: parent.width
                    spacing: Theme.gap

                    Tile {
                        width: (parent.width - parent.spacing) / 2
                        icon: "󰚰"
                        title: "Updates"
                        subtitle: Updates.checking ? "Checking..." : Updates.count === 0 ? "Up to date" : Updates.count + " available"
                        active: Updates.count > 0
                        tint: Updates.level === "critical" ? Theme.error : Updates.level === "warning" ? Theme.warn : Theme.accent
                        onClicked: {
                            Updates.run();
                            root.close();
                        }
                    }
                    Tile {
                        width: (parent.width - parent.spacing) / 2
                        icon: Idle.inhibited ? "󰅶" : "󰾪"
                        title: "Keep awake"
                        subtitle: Idle.inhibited ? "On" : "Off"
                        active: Idle.inhibited
                        onClicked: Idle.toggle()
                    }
                }

                SliderRow {
                    width: parent.width
                    icon: Audio.icon
                    value: Audio.volume
                    muted: Audio.muted
                    onMoved: (v) => {
                        return Audio.setVolume(v);
                    }
                    onIconClicked: Audio.toggleMute()
                }

                BrightnessRow {
                    width: parent.width
                }

                NotifList {
                    width: parent.width
                }

            }

        }

        HoverHandler {
            id: popupHover
        }

    }

    Behavior on progress {
        NumberAnimation {
            duration: Theme.animDuration
            easing.type: Easing.OutCubic
        }

    }

    mask: Region {
        item: card
    }

}
