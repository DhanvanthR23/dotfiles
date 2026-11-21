import "../../components"
import "../../config"
import "../../services"
import QtQuick

Item {
    id: root

    property bool open: false

    height: open ? card.height : 0
    visible: open
    clip: true

    Rectangle {
        id: card

        width: parent.width
        height: list.implicitHeight + 16
        radius: Theme.radiusItem
        color: "transparent"
        border.width: 1
        border.color: Theme.border

        Column {
            id: list

            x: 8
            y: 8
            width: parent.width - 16
            spacing: 2

            Text {
                visible: Audio.streams.length === 0
                width: parent.width
                height: 28
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Nothing playing"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            Repeater {
                model: Audio.streams

                Column {
                    id: app

                    required property var modelData

                    width: list.width

                    Text {
                        width: parent.width
                        leftPadding: 40 // lines up with the slider track
                        text: Audio.appName(app.modelData)
                        elide: Text.ElideRight
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                    }

                    SliderRow {
                        width: parent.width
                        icon: app.modelData.audio.muted ? "󰝟" : "󰕾"
                        value: app.modelData.audio.volume
                        muted: app.modelData.audio.muted
                        onMoved: (v) => { app.modelData.audio.volume = Math.max(0, Math.min(1, v)); }
                        onIconClicked: app.modelData.audio.muted = !app.modelData.audio.muted
                    }
                }
            }
        }
    }
}
