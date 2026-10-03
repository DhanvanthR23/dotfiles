import QtQuick
import "../../config"
import "../../services"

Column {
    id: root
    spacing: 8

    readonly property int rowHeight: 52
    readonly property int rowGap: 6
    readonly property int visibleRows: 3

    // divider
    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    // header
    Item {
        width: parent.width
        height: 24

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Notifications"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
        }

        Text {
            id: clearLabel
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: Notifs.count > 0
            text: "Clear all"
            color: clearHover.hovered ? Theme.accent : Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
            Behavior on color { ColorAnimation { duration: 120 } }

            HoverHandler { id: clearHover; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: Notifs.clearAll() }
        }
    }

    // empty state
    Text {
        visible: Notifs.count === 0
        width: parent.width
        height: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "No notifications"
        color: Theme.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
    }

    // the list: grows with its content up to 3 rows, then scrolls
    ListView {
        id: list
        visible: Notifs.count > 0
        width: parent.width
        height: Math.min(contentHeight,
                         root.visibleRows * root.rowHeight + (root.visibleRows - 1) * root.rowGap)
        spacing: root.rowGap
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: Notifs.newestFirst

        delegate: Rectangle {
            id: row
            required property var modelData

            width: ListView.view.width
            height: root.rowHeight
            radius: 14
            color: Theme.surfaceAlt
            border.width: 1
            border.color: Notifs.isCritical(modelData) ? Theme.error : Theme.border

            Rectangle {
                id: avatar
                width: 28
                height: 28
                radius: 14
                color: Theme.surface
                anchors {
                    left: parent.left
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.centerIn: parent
                    text: row.modelData.appName.charAt(0).toUpperCase()
                    color: Notifs.isCritical(row.modelData) ? Theme.error
                         : Notifs.isLow(row.modelData) ? Theme.textMuted
                         : Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }

            Column {
                anchors {
                    left: avatar.right
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 40            // room for the close button
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    width: parent.width
                    text: row.modelData.summary
                    color: Theme.text
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    font.bold: true
                }
                Text {
                    width: parent.width
                    text: row.modelData.body
                    color: Theme.textMuted
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                }
            }

            // close button, only visible while hovering the row
            Item {
                width: 24
                height: 24
                anchors {
                    right: parent.right
                    rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                opacity: rowHover.hovered ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: Theme.surface
                    opacity: closeHover.hovered ? 1 : 0
                }
                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: closeHover.hovered ? Theme.error : Theme.textMuted
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.fontSize
                }
                HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: Notifs.dismiss(row.modelData) }
            }

            HoverHandler { id: rowHover }
        }
    }
}
