import "../../components"
import "../../config"
import "../../services"
import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item pill // the ClockPill
    readonly property int headerHeight: 32
    readonly property int stripHeight: 52
    readonly property int mediaHeight: 36
    property bool expanded: false
    property real detail: expanded ? 1 : 0
    readonly property int weatherHeight: 28
    readonly property int topBlocks: (Media.available ? 1 : 0) + (Weather.ready ? 1 : 0)
    readonly property real contentHeight: Theme.padding * 2 * (topBlocks > 0 ? 1 : detail)
        + (Media.available ? mediaHeight : 0)
        + (Weather.ready ? weatherHeight : 0)
        + Math.max(0, topBlocks - 1) * Theme.gap
        + (topBlocks > 0 ? Theme.gap * detail : 0)
        + (headerHeight + Theme.gap + stripHeight) * detail
    property real textY: (topBlocks > 0 || expanded) ? 10 : 0
    Behavior on textY {
        NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic }
    }
    Behavior on detail {
        NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic }
    }
    // --- week strip data ---
    readonly property var today: Time.now
    property int weekOffset: 0   // target week, changes instantly on click
    property int shownOffset: 0  // week the strip actually displays, swaps at the animation midpoint
    property int slideDir: 1     // -1 = went back, 1 = went forward
    readonly property var stripStart: {
        const d = new Date(today.getFullYear(), today.getMonth(), today.getDate());
        d.setDate(d.getDate() - 3 + shownOffset * 7);
        return d;
    }
    readonly property var centerDay: {
        const d = new Date(stripStart);
        d.setDate(d.getDate() + 3);
        return d;
    }
    // --- open/close logic ---
    property bool open: false
    readonly property bool wantOpen: pill.hovered || popupHover.hovered
    readonly property bool shown: open && !Notifs.toastVisible
    property real progress: shown ? 1 : 0
    readonly property real fade: Math.max(0, progress * 2 - 1) // 0 in the first half, ramps to 1 in the second

    function go(dir) {
        slideDir = dir;
        weekOffset += dir;
        flip.restart();
    }

    onWantOpenChanged: {
        if (wantOpen) {
            closeTimer.stop();
            open = true;
        } else {
            closeTimer.restart();
        }
    }
    onProgressChanged: {
        if (progress === 0) {
            flip.stop();
            weekOffset = 0;
            shownOffset = 0;
            strip.x = 0;
            strip.opacity = 1;
            expanded = false;
        }
    }
    // window sits exactly on top of the pill, card grows downward from there
    anchor.item: pill
    anchor.rect.x: (pill.width - width) / 2
    anchor.rect.y: 0
    implicitWidth: Theme.toastWidth
    implicitHeight: Theme.pillHeight + contentHeight
    visible: shown || progress > 0 // stay mapped while shrinking
    color: "transparent"

    Timer {
        id: closeTimer

        interval: 150
        onTriggered: root.open = false
    }

    Rectangle {
        id: card

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.pill.width
        height: Theme.pillHeight + root.contentHeight * root.progress
        radius: Math.min(height / 2, Theme.radius)
        color: Theme.surface
        border.width: 1
        border.color: Theme.border
        clip: true

        // clock text, same spot as in the pill so the handoff is seamless
        Text {
            y: root.textY
            height: Theme.pillHeight
            verticalAlignment: Text.AlignVCenter
            // centered at progress 0, left padding at progress 1
            x: (card.width - width) / 2 * (1 - root.progress) + Theme.padding * root.progress
            text: Time.time
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            y: root.textY
            height: Theme.pillHeight
            verticalAlignment: Text.AlignVCenter
            text: Time.dateShort
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSmall
            opacity: root.fade // same fade as the calendar content
        }
        // calendar content: fixed size, revealed by the growing card, fades in 2nd half

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.pillHeight
            width: root.implicitWidth
            height: root.contentHeight
            enabled: root.shown


            Column {
                anchors.fill: parent
                anchors.margins: Theme.padding
                spacing: Theme.gap

                Item {
                    visible: Media.available
                    width: parent.width
                    height: root.mediaHeight

                    Column {
                        anchors {
                            left: parent.left
                            right: controls.left
                            rightMargin: Theme.gap
                            verticalCenter: parent.verticalCenter
                        }

                        Text {
                            width: parent.width
                            text: Media.title
                            color: Theme.text
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                            font.bold: true
                        }

                        Text {
                            width: parent.width
                            text: Media.artist
                            color: Theme.textMuted
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontCaption
                        }

                    }

                    Row {
                        id: controls

                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        ArrowButton {
                            label: "󰒮"
                            onClicked: Media.previous()
                        }

                        ArrowButton {
                            label: Media.playing ? "󰏤" : "󰐊"
                            onClicked: Media.toggle()
                        }

                        ArrowButton {
                            label: "󰒭"
                            onClicked: Media.next()
                        }

                    }

                }

                Item {
                    visible: Weather.ready
                    width: parent.width
                    height: root.weatherHeight

                    Row {
                        anchors.left: parent.left
                        height: parent.height
                        spacing: 8

                        Text {
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            text: Weather.icon
                            color: Theme.accent
                            font.family: Theme.iconFont
                            font.pixelSize: Theme.iconSize
                        }

                        Text {
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            text: Math.round(Weather.temp) + "° " + Weather.condition
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                            font.bold: true
                        }
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "H " + Math.round(Weather.high) + "°  L " + Math.round(Weather.low) + "°  ·  feels " + Math.round(Weather.feels) + "°"
                        color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontCaption
                    }
                }

                Item {
                    width: parent.width
                    visible: root.detail > 0
                    opacity: root.detail
                    height: 32

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDate(root.centerDay, "MMMM yyyy")
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        ArrowButton {
                            label: "‹"
                            nudge: -2
                            onClicked: root.go(-1)
                        }

                        ArrowButton {
                            label: "›"
                            nudge: 2
                            onClicked: root.go(1)
                        }

                    }

                }

                // clipping window so the sliding strip never leaks outside its slot
                Item {
                    width: parent.width
                    height: 52
                    clip: true

                    Row {
                        id: strip

                        width: parent.width
                        visible: root.detail > 0
                        opacity: root.detail

                        Repeater {
                            model: 7

                            Item {
                                id: cell

                                required property int index
                                readonly property var day: {
                                    const d = new Date(root.stripStart);
                                    d.setDate(d.getDate() + index);
                                    return d;
                                }
                                readonly property bool isToday: day.toDateString() === root.today.toDateString()

                                width: parent.width / 7
                                height: 52

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width - 6
                                    height: parent.height
                                    radius: Theme.radiusItem
                                    color: cell.isToday ? Theme.accent : "transparent"

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: Qt.formatDate(cell.day, "ddd")
                                            color: cell.isToday ? Theme.bg : Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontCaption
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: cell.day.getDate()
                                            color: cell.isToday ? Theme.bg : Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.bold: cell.isToday
                                        }

                                    }

                                }

                            }

                        }

                        // out: slide + fade away -> swap data -> in: slide + fade back from the other side
                        SequentialAnimation {
                            id: flip

                            ParallelAnimation {
                                NumberAnimation {
                                    target: strip
                                    property: "x"
                                    to: -root.slideDir * 24
                                    duration: Theme.animFast
                                    easing.type: Easing.InCubic
                                }

                                NumberAnimation {
                                    target: strip
                                    property: "opacity"
                                    to: 0
                                    duration: Theme.animFast
                                }

                            }

                            ScriptAction {
                                script: {
                                    root.shownOffset = root.weekOffset;
                                    strip.x = root.slideDir * 24;
                                }
                            }

                            ParallelAnimation {
                                NumberAnimation {
                                    target: strip
                                    property: "x"
                                    to: 0
                                    duration: Theme.animDuration
                                    easing.type: Easing.OutCubic
                                }

                                NumberAnimation {
                                    target: strip
                                    property: "opacity"
                                    to: 1
                                    duration: Theme.animDuration
                                }

                            }

                        }

                    }

                }



            }

        }
        // update dot, same spot as on the pill so the handoff is invisible

        UpdateDot {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 1
                rightMargin: 1
            }
        }

        Item {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: Theme.pillHeight + 10
            TapHandler { onTapped: root.expanded = !root.expanded }
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

    // only the card catches the mouse, transparent window area doesn't block other pills
    mask: Region {
        item: card
    }

}
