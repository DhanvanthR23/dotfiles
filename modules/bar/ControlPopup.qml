import Quickshell
import QtQuick
import "../../config"
import "../../services"

PopupWindow {
    id: root
    required property Item pill

    readonly property int cardWidth: 340
    readonly property int contentHeight: body.implicitHeight + Theme.padding * 2

    // --- open/close ---
    property bool open: false
    function toggle() { open = !open }
    function close() { open = false }

    // pointer counts as "inside" on the pill or on the card
    readonly property bool inside: pill.hovered || popupHover.hovered
    onInsideChanged: {
        if (inside) leaveTimer.stop()
        else if (open) leaveTimer.restart()
    }
    onOpenChanged: {
        if (open) Brightness.refresh()
        else leaveTimer.stop()
    }
    Timer { id: leaveTimer; interval: 1000; onTriggered: root.close() }

    // --- animation driver: 0 = pill, 1 = full card ---
    property real progress: open ? 1 : 0
    Behavior on progress {
        NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic }
    }

    // window's top-left corner sits on the pill's top-left corner
    anchor.item: pill
    anchor.rect.x: 0
    anchor.rect.y: 0

    implicitWidth: cardWidth
    implicitHeight: Theme.pillHeight + contentHeight
    visible: open || progress > 0
    color: "transparent"
    mask: Region { item: card }

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
            opacity: Math.max(0, root.progress * 2 - 1)
        }
        Item {
            y: Theme.pillHeight
            width: root.cardWidth
            height: root.contentHeight
            opacity: Math.max(0, root.progress * 2 - 1)   // fades in during the 2nd half, like the calendar
            enabled: root.open

            Column {
                id: body
                x: Theme.padding
                y: Theme.padding
                width: parent.width - Theme.padding * 2
                spacing: 10

                Row {
                    width: parent.width
                    spacing: 10

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
                    spacing: 10

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
                        subtitle: NightLight.mode === "off" ? "Off"
                                : NightLight.mode === "now" ? "On"
                                : "Auto"
                        active: NightLight.enabled
                        onClicked: NightLight.cycle()
                    }
                }
                SliderRow {
                    width: parent.width
                    icon: Audio.icon
                    value: Audio.volume
                    muted: Audio.muted
                    onMoved: v => Audio.setVolume(v)
                    onIconClicked: Audio.toggleMute()
                }
                Column {
                    width: parent.width
                    spacing: 6

                    SliderRow {
                        width: parent.width
                        icon: "󰃟"
                        value: Brightness.position
                        interactive: Brightness.controllable
                        onMoved: v => Brightness.setPosition(v)
                        onIconClicked: monitorList.open = !monitorList.open
                    }

                    Item {
                        id: monitorList
                        property bool open: false
                        width: parent.width
                        height: open ? list.implicitHeight : 0
                        visible: open
                        clip: true

                        Column {
                            id: list
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: Brightness.names

                                Rectangle {
                                    id: mon
                                    required property string modelData
                                    readonly property bool picked: modelData === Brightness.current

                                    width: list.width
                                    height: 32
                                    radius: 10
                                    color: picked || monHover.hovered ? Theme.surfaceAlt : "transparent"
                                    border.width: 1
                                    border.color: picked ? Theme.accent : "transparent"

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: Theme.padding
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: mon.modelData
                                        color: Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 1
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        anchors.rightMargin: Theme.padding
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Brightness.isInternal(mon.modelData) ? "Built-in"
                                            : Brightness.ddcDisplays[mon.modelData] ? "External" : "No DDC"
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 3
                                    }

                                    HoverHandler { id: monHover; cursorShape: Qt.PointingHandCursor }
                                    TapHandler {
                                        onTapped: {
                                            Brightness.selected = mon.modelData
                                            monitorList.open = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                NotifList { width: parent.width }
            }

        }

        HoverHandler { id: popupHover }
    }
}
