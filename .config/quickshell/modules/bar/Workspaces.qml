import "../../components"
import "../../config"
import "../../services"
import QtQuick
import Quickshell

Pill {
    id: root

    property string screenName
    readonly property real dotSize: 10
    readonly property real focusedSize: 20
    readonly property real dotGap: 6
    readonly property int maxDots: 4
    // room for 4 workspaces, so the pill stays put while they come and go
    readonly property real fixedWidth: focusedSize + (maxDots - 1) * (dotSize + dotGap) + Theme.padding * 2

    // never smaller than the fixed width, but grows if a 5th workspace ever shows up
    implicitWidth: Math.max(fixedWidth, row.implicitWidth + Theme.padding * 2)
    hoverable: false

    property bool scrollReady: true

    signal rightClicked()

    Timer {
        id: scrollCooldown

        interval: 150
        onTriggered: root.scrollReady = true
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: (wheel) => {
            if (!root.scrollReady || wheel.angleDelta.y === 0)
                return;
            Quickshell.execDetached(["niri", "msg", "action", wheel.angleDelta.y > 0 ? "focus-workspace-up" : "focus-workspace-down"]);
            root.scrollReady = false;
            scrollCooldown.restart();
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: root.dotGap

        // remove: import Quickshell.Niri
        Repeater {
            model: NiriService.workspaces

            Item {
                id: dot

                required property var model
                readonly property bool occupied: model.activeWindowId !== 0

                visible: model.output === root.screenName
                width: model.isFocused ? root.focusedSize : root.dotSize
                height: root.height

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: root.dotSize
                    radius: height / 2
                    color: dot.model.isFocused ? Theme.accent : dot.occupied ? Theme.textMuted : Theme.border
                }

                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: NiriService.focusWorkspace(dot.model.id) }

                Behavior on width { NumberAnimation { duration: Theme.animDuration } }
            }
        }

    }
    TapHandler { acceptedButtons: Qt.RightButton; onTapped: Quickshell.execDetached(["niri", "msg", "action", "toggle-overview"]) }

}
