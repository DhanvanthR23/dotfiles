import QtQuick
import "../../config"
import "../../services"
import "../../components"

Column {
    id: root
    spacing: 6

    SliderRow {
        width: parent.width
        icon: "󰃟"
        value: Brightness.position
        interactive: Brightness.controllable
        onMoved: v => Brightness.setPosition(v)
        onIconClicked: monitorList.open = !monitorList.open
    }

    Item {
        id: monitorList
        property bool open: false
        width: parent.width
        height: open ? list.implicitHeight : 0
        visible: open
        clip: true

        Column {
            id: list
            width: parent.width
            spacing: 4

            Repeater {
                model: Brightness.names

                Rectangle {
                    id: mon
                    required property string modelData
                    readonly property bool picked: modelData === Brightness.current

                    width: list.width
                    height: 32
                    radius: Theme.radiusSmall
                    color: picked || monHover.hovered ? Theme.surfaceAlt : "transparent"
                    border.width: 1
                    border.color: picked ? Theme.accent : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.padding
                        anchors.verticalCenter: parent.verticalCenter
                        text: mon.modelData
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.padding
                        anchors.verticalCenter: parent.verticalCenter
                        text: Brightness.isInternal(mon.modelData) ? "Built-in"
                            : Brightness.ddcDisplays[mon.modelData] ? "External" : "No DDC"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                    }

                    HoverHandler { id: monHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            Brightness.selected = mon.modelData
                            monitorList.open = false
                        }
                    }
                }
            }
        }
    }
}
