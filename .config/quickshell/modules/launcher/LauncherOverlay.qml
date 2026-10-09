import "../../config"
import "../../services"
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var popup
    readonly property int rowHeight: 32
    readonly property int topPad: 4
    readonly property int rowGap: 4
    readonly property int count: Launcher.results.length
    readonly property real listHeight: count > 0 ? count * rowHeight + (count - 1) * rowGap : rowHeight
    property real bodyHeight: listHeight + Theme.padding * 2

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
        onClicked: root.popup.close()
    }

    Rectangle {
        id: card

        // sits exactly where the clock pill sits
        y: Theme.gap + (Theme.barHeight - Theme.pillHeight) / 2
        x: root.popup.startX + ((root.width - width) / 2 - root.popup.startX) * root.popup.travel
        width: Theme.pillHeight + (Theme.launcherWidth - Theme.pillHeight) * root.popup.fade
        height: Theme.pillHeight + (root.bodyHeight + root.topPad) * root.popup.fade
        radius: Math.min(height / 2, Theme.radius)
        color: Theme.surface
        border.width: 1
        border.color: Theme.border
        clip: true

        // swallow clicks so they don't reach the backdrop
        MouseArea {
            anchors.fill: parent
            enabled: root.popup.open
            acceptedButtons: Qt.AllButtons
            onClicked: root.popup.close()
        }

        Text {
            id: glyph

            height: Theme.pillHeight
            // centered while it's a circle, left-aligned once expanded
            x: (card.width - width) / 2 * (1 - root.popup.fade) + Theme.padding * root.popup.fade
            y: root.topPad * root.popup.fade
            verticalAlignment: Text.AlignVCenter
            text: "󰍉"
            color: Theme.accent
            font.family: Theme.iconFont
            font.pixelSize: Theme.fontSize
        }

        TextInput {
            id: input

            x: Theme.padding + glyph.width + Theme.gap
            y: root.topPad * root.popup.fade
            width: card.width - x - Theme.padding
            height: Theme.pillHeight
            verticalAlignment: TextInput.AlignVCenter
            opacity: root.popup.fade
            focus: true
            color: Theme.text
            selectionColor: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            clip: true
            onTextChanged: Launcher.query = text
            Keys.onEscapePressed: root.popup.close()
            Keys.onDownPressed: Launcher.move(1)
            Keys.onUpPressed: Launcher.move(-1)
            Keys.onTabPressed: Launcher.move(1)
            Keys.onBacktabPressed: Launcher.move(-1)
            Keys.onReturnPressed: {
                if (Launcher.activateSelected())
                    root.popup.close();

            }
            Keys.onEnterPressed: {
                if (Launcher.activateSelected())
                    root.popup.close();

            }

            Text {
                visible: input.text === ""
                text: "Search apps or calculate…"
                color: Theme.textMuted
                font: input.font
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        // results body: fixed width, centered, so the card's growth reveals it
        Item {
            id: body

            width: Theme.launcherWidth - Theme.padding * 2
            height: root.listHeight
            x: (card.width - width) / 2
            y: Theme.pillHeight + Theme.padding + root.topPad * root.popup.fade
            opacity: root.popup.fade

            // sliding selection highlight
            Rectangle {
                visible: root.count > 0
                width: parent.width
                height: root.rowHeight
                y: Launcher.selected * (root.rowHeight + root.rowGap)
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
                text: "No results"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            Repeater {
                model: Launcher.results

                Item {
                    id: row

                    required property var modelData
                    required property int index

                    y: index * (root.rowHeight + root.rowGap)
                    width: body.width
                    height: root.rowHeight

                    Text {
                        text: row.modelData.kind === "calc" ? "= " + row.modelData.title : row.modelData.title
                        color: row.modelData.kind === "calc" ? Theme.accent : Theme.text
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSmall

                        anchors {
                            left: parent.left
                            leftMargin: Theme.padding
                            right: sub.left
                            rightMargin: Theme.gap
                            verticalCenter: parent.verticalCenter
                        }

                    }

                    Text {
                        id: sub

                        width: Math.min(implicitWidth, row.width * 0.4)
                        horizontalAlignment: Text.AlignRight
                        text: row.modelData.subtitle
                        color: Theme.textMuted
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption

                        anchors {
                            right: parent.right
                            rightMargin: Theme.padding
                            verticalCenter: parent.verticalCenter
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: Launcher.selected = row.index
                        onClicked: {
                            Launcher.activate(row.modelData);
                            root.popup.close();
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
