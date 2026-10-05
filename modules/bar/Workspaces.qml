import "../../components"
import "../../config"
import QtQuick
import Quickshell.Niri

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

    Row {
        id: row

        anchors.centerIn: parent
        spacing: root.dotGap

        Repeater {
            model: Niri.workspaces

            Item {
                id: dot

                required property var modelData

                visible: modelData.output === root.screenName
                width: modelData.focused ? root.focusedSize : root.dotSize
                height: root.height

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: root.dotSize
                    radius: height / 2
                    color: dot.modelData.focused ? Theme.accent : dot.modelData.occupied ? Theme.textMuted : Theme.border
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: Niri.dispatch(["focus-workspace", String(dot.modelData.idx)])
                }

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.animDuration
                    }
                }
            }
        }
    }
}
