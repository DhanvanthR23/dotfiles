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
    readonly property int contentHeight: Theme.padding * 2 + headerHeight + Theme.gap + stripHeight + (Media.available ? Theme.gap + mediaHeight : 0)
    // --- week strip data ---
    readonly property var today: Time.now
    property int weekOffset: 0
    readonly property var stripStart: {
        const d = new Date(today.getFullYear(), today.getMonth(), today.getDate());
        d.setDate(d.getDate() - 3 + weekOffset * 7);
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
    // --- animation driver: 0 = pill, 1 = full popup ---
    readonly property bool shown: open && !Notifs.toastVisible
    property real progress: shown ? 1 : 0
    readonly property real fade: Math.max(0, progress * 2 - 1) // 0 in the first half, ramps to 1 in the second
    signal pickerRequested()

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
            weekOffset = 0;
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
            y: 10
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
            y: 10
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
            opacity: root.fade
            enabled: root.shown

            Column {
                anchors.fill: parent
                anchors.margins: Theme.padding
                spacing: Theme.gap

                Item {
                    width: parent.width
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
                            onClicked: root.weekOffset--
                        }

                        ArrowButton {
                            label: "›"
                            nudge: 2
                            onClicked: root.weekOffset++
                        }

                    }

                }

                Row {
                    width: parent.width

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

                }
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

            }

        }
        // update dot, same spot as on the pill so the handoff is invisible

        UpdateDot {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 2
                rightMargin: 4
            }

        }

        // temporary picker opener: right-click works while the calendar is expanded
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: root.pill.pickerRequested()
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
    // reset week only once fully collapsed, so it doesn't jump mid-animation

    // only the card catches the mouse, transparent window area doesn't block other pills
    mask: Region {
        item: card
    }

}
