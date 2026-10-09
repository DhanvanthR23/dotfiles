import "../../config"
import "../../services"
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var popup
    readonly property int cardWidth: Theme.launcherWidth
    readonly property int rowHeight: 32
    readonly property int rowGap: 4
    readonly property int count: Clip.results.length
    readonly property real listHeight: count > 0 ? count * rowHeight + (count - 1) * rowGap : rowHeight
    readonly property real fade: Math.max(0, popup.progress * 2 - 1)
    property real bodyHeight: listHeight

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: popup.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // click outside the card closes
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: Clip.hide()
    }

    Rectangle {
        id: card

        readonly property real startWidth: root.popup.pill.idleWidth

        // grows out of the clock pill, downward
        y: Theme.gap + (Theme.barHeight - Theme.pillHeight) / 2
        x: (root.width - width) / 2
        width: startWidth + (root.cardWidth - startWidth) * root.popup.progress
        height: Theme.pillHeight + (root.bodyHeight + Theme.padding * 2) * root.popup.progress
        radius: Math.min(height / 2, Theme.radius)
        color: Theme.surface
        border.width: 1
        border.color: Theme.border
        clip: true

        // swallow clicks so they don't reach the backdrop
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        Text {
            id: glyph

            height: Theme.pillHeight
            x: (card.width - width) / 2 * (1 - root.popup.progress) + Theme.padding * root.popup.progress
            verticalAlignment: Text.AlignVCenter
            text: "\udb80\udd47" // nf-md-clipboard
            color: Theme.accent
            font.family: Theme.iconFont
            font.pixelSize: Theme.fontSize
        }

        TextInput {
            id: input

            x: Theme.padding + glyph.width + Theme.gap
            width: card.width - x - Theme.padding
            height: Theme.pillHeight
            verticalAlignment: TextInput.AlignVCenter
            opacity: root.fade
            focus: true
            color: Theme.text
            selectionColor: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            clip: true
            onTextChanged: Clip.query = text
            Keys.onEscapePressed: Clip.hide()
            Keys.onDownPressed: Clip.move(1)
            Keys.onUpPressed: Clip.move(-1)
            Keys.onTabPressed: Clip.move(1)
            Keys.onBacktabPressed: Clip.move(-1)
            Keys.onReturnPressed: Clip.activateSelected()
            Keys.onEnterPressed: Clip.activateSelected()
            Keys.onDeletePressed: Clip.deleteSelected()

            Text {
                visible: input.text === ""
                text: "clipboard…"
                color: Theme.textMuted
                font: input.font
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        // fixed width, centered, so the card's growth reveals it
        Item {
            id: body

            width: root.cardWidth - Theme.padding * 2
            height: root.listHeight
            x: (card.width - width) / 2
            y: Theme.pillHeight + Theme.padding
            opacity: root.fade

            // sliding selection highlight
            Rectangle {
                visible: root.count > 0
                width: parent.width
                height: root.rowHeight
                y: Clip.selected * (root.rowHeight + root.rowGap)
                radius: Theme.radiusSmall
                color: Theme.surfaceAlt
                border.width: 1
                border.color: Theme.accent

                Behavior on y {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutCubic
                    }

                }

            }

            Text {
                visible: root.count === 0 && !Clip.loading
                width: parent.width
                height: root.rowHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Clip.needle === "" ? "Clipboard is empty" : "No match"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            Repeater {
                model: Clip.results

                Item {
                    id: row

                    required property var modelData
                    required property int index

                    y: index * (root.rowHeight + root.rowGap)
                    width: body.width
                    height: root.rowHeight

                    Text {
                        text: row.modelData.text
                        // image entries show up as "[[ binary data ... ]]"
                        color: row.modelData.text.startsWith("[[ binary data") ? Theme.textMuted : Theme.text
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSmall

                        anchors {
                            left: parent.left
                            leftMargin: Theme.padding
                            right: parent.right
                            rightMargin: Theme.padding
                            verticalCenter: parent.verticalCenter
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: Clip.selected = row.index
                        onClicked: {
                            Clip.selected = row.index;
                            Clip.activateSelected();
                        }
                    }

                }

            }

        }

    }

    Behavior on bodyHeight {
        NumberAnimation {
            duration: Theme.animDuration
            easing.type: Easing.OutCubic
        }

    }

}
