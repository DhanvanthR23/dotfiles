import QtQuick
import Quickshell.Niri
import "../../config"
import "../../components"

Pill {
    id: root
    property string screenName

    implicitWidth: row.implicitWidth + Theme.padding * 2
    hoverable: false

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
                    NumberAnimation { duration: Theme.animDuration }
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
