import QtQuick
import Quickshell.Niri
import "../../config"

Rectangle {
    id: root
    property string screenName

    implicitWidth: row.implicitWidth + Theme.padding * 2
    implicitHeight: Theme.pillHeight
    radius: height / 2
    color: Theme.surface
    border.width: 1
    border.color: Theme.border

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: Niri.workspaces

            Item {
                id: dot
                required property var modelData

                visible: modelData.output === root.screenName
                width: modelData.focused ? 20 : 10
                height: root.height

                Behavior on width {
                    NumberAnimation { duration: 150 }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 10
                    radius: height / 2
                    color: dot.modelData.focused ? Theme.accent
                         : dot.modelData.occupied ? Theme.textMuted
                         : Theme.border
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: Niri.dispatch(["focus-workspace", String(dot.modelData.idx)])
                }
            }
        }
    }
}
