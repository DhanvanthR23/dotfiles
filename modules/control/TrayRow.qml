import "../../config"
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Column {
    id: root

    property bool active: true // false while the popup is closed
    property var shownMenu: null // menu currently shown in the card
    property var trail: [] // menus we came from, for the back row

    visible: SystemTray.items.values.length > 0
    spacing: 6
    onActiveChanged: {
        if (!active) {
            shownMenu = null;
            trail = [];
        }
    }

    Flow {
        width: parent.width
        spacing: 6

        Repeater {
            model: SystemTray.items

            Rectangle {
                id: cell

                required property var modelData

                function openMenu() {
                    if (!modelData.hasMenu)
                        return;
                    root.trail = [];
                    root.shownMenu = root.shownMenu === modelData.menu ? null : modelData.menu;
                }

                width: 32
                height: 32
                radius: Theme.radiusSmall
                color: hover.hovered ? Theme.surfaceAlt : "transparent"

                Image {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    source: cell.modelData.icon
                    sourceSize: Qt.size(36, 36)
                }

                HoverHandler {
                    id: hover

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: cell.modelData.onlyMenu ? cell.openMenu() : cell.modelData.activate()
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: cell.openMenu()
                }
            }
        }
    }

    // the app menu, drawn inside the card
    Column {
        width: parent.width
        spacing: 2
        visible: root.shownMenu !== null

        Rectangle {
            visible: root.trail.length > 0
            width: parent.width
            height: 28
            radius: Theme.radiusSmall
            color: backHover.hovered ? Theme.surfaceAlt : "transparent"

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.padding
                anchors.verticalCenter: parent.verticalCenter
                text: "‹  Back"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            HoverHandler {
                id: backHover

                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    root.shownMenu = root.trail[root.trail.length - 1];
                    root.trail = root.trail.slice(0, -1);
                }
            }
        }

        ListView {
            id: menuList

            readonly property int maxHeight: 8 * 30 // about 8 rows, then scroll

            width: parent.width
            height: Math.min(contentHeight, maxHeight)
            spacing: 2
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: opener.children
            onModelChanged: positionViewAtBeginning()

            delegate: Rectangle {
                id: entry

                required property var modelData

                width: ListView.view.width
                height: modelData.isSeparator ? 1 : 28
                radius: Theme.radiusSmall
                color: modelData.isSeparator ? Theme.border : entryHover.hovered && modelData.enabled ? Theme.surfaceAlt : "transparent"

                Text {
                    visible: !entry.modelData.isSeparator
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.padding
                    anchors.right: arrow.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: entry.modelData.text
                    elide: Text.ElideRight
                    color: entry.modelData.enabled ? Theme.text : Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                }

                Text {
                    id: arrow

                    visible: entry.modelData.hasChildren
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padding
                    anchors.verticalCenter: parent.verticalCenter
                    text: "›"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                }

                HoverHandler {
                    id: entryHover

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    enabled: !entry.modelData.isSeparator && entry.modelData.enabled
                    onTapped: {
                        if (entry.modelData.hasChildren) {
                            root.trail = root.trail.concat([root.shownMenu]);
                            root.shownMenu = entry.modelData;
                        } else {
                            entry.modelData.triggered();
                            root.shownMenu = null;
                        }
                    }
                }
            }
        }
    }

    QsMenuOpener {
        id: opener

        menu: root.shownMenu
    }
}
