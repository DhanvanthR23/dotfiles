import "../../config"
import "../../services"
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var popup
    readonly property int rowHeight: 32
    readonly property int rowGap: 4
    readonly property int count: Session.results.length
    readonly property real listHeight: count > 0 ? count * rowHeight + (count - 1) * rowGap : rowHeight
    readonly property real fade: Math.max(0, popup.progress * 2 - 1)
    property real bodyHeight: listHeight
    readonly property int cardWidth: Theme.sessionWidth

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
        onClicked: Session.hide()
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
            text: "\udb81\udc25" // nf-md-power
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
            onTextChanged: Session.query = text
            Keys.onEscapePressed: Session.hide()
            Keys.onDownPressed: Session.move(1)
            Keys.onUpPressed: Session.move(-1)
            Keys.onTabPressed: Session.move(1)
            Keys.onBacktabPressed: Session.move(-1)
            Keys.onReturnPressed: Session.activateSelected()
            Keys.onEnterPressed: Session.activateSelected()

            Text {
                visible: input.text === ""
                text: "session…"
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
                y: Session.selected * (root.rowHeight + root.rowGap)
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
                visible: root.count === 0
                width: parent.width
                height: root.rowHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "No match"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            Repeater {
                model: Session.results

                Item {
                    id: row

                    required property var modelData
                    required property int index

                    y: index * (root.rowHeight + root.rowGap)
                    width: body.width
                    height: root.rowHeight

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.padding
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.label
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: Session.selected = row.index
                        onClicked: {
                            Session.selected = row.index;
                            Session.activateSelected();
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
