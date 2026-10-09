import "../../config"
import "../../services"
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var popup
    readonly property int cardWidth: 560
    readonly property int rowHeight: 32
    readonly property int rowGap: 4
    readonly property int maxRows: 7
    readonly property int thumbW: 160
    readonly property int thumbH: 90
    readonly property real fade: Math.max(0, popup.progress * 2 - 1)
    readonly property real themesHeight: Math.min(Math.max(Themes.themes.length, 1), maxRows) * (rowHeight + rowGap) - rowGap
    readonly property real wallsHeight: thumbH + 8
    property real bodyHeight: Picker.view === "themes" ? themesHeight : wallsHeight
    property int ti: 0 // keyboard/hover selection, themes
    property int wi: 0 // keyboard/hover selection, wallpapers

    function syncThemes() {
        ti = Math.max(0, Themes.themes.findIndex((t) => {
            return t.slug === Themes.current;
        }));
    }

    function syncWalls() {
        wi = Math.max(0, Themes.wallpapers.findIndex((w) => {
            return w.path === Themes.currentWall;
        }));
    }

    function move(d) {
        if (Picker.view === "themes") {
            const n = Themes.themes.length;
            if (n > 0)
                ti = (ti + d + n) % n;

        } else {
            const n = Themes.wallpapers.length;
            if (n > 0)
                wi = Math.max(0, Math.min(n - 1, wi + d));

        }
    }

    function flip() {
        Picker.view = Picker.view === "themes" ? "walls" : "themes";
    }

    function activate() {
        if (Picker.view === "themes") {
            const t = Themes.themes[ti];
            if (t) {
                Themes.apply(t.slug);
                Picker.hide();
            }
        } else {
            const w = Themes.wallpapers[wi];
            if (w)
                Themes.setWallpaper(w.path);

        }
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: popup.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onTiChanged: themeList.positionViewAtIndex(ti, ListView.Contain)
    onWiChanged: wallList.positionViewAtIndex(wi, ListView.Contain)
    Component.onCompleted: {
        syncThemes();
        syncWalls();
    }

    Connections {
        function onThemesChanged() {
            root.syncThemes();
        }

        function onWallpapersChanged() {
            root.syncWalls();
        }

        target: Themes
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Picker.hide()
        Keys.onTabPressed: root.flip()
        Keys.onBacktabPressed: root.flip()
        Keys.onUpPressed: root.move(-1)
        Keys.onLeftPressed: root.move(-1)
        Keys.onDownPressed: root.move(1)
        Keys.onRightPressed: root.move(1)
        Keys.onReturnPressed: root.activate()
        Keys.onEnterPressed: root.activate()

        // click outside the card closes
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: Picker.hide()
        }

        Rectangle {
            id: card

            readonly property real startWidth: 96

            // grows out of the clock pill, downward
            y: Theme.gap + (Theme.barHeight - Theme.pillHeight) / 2
            anchors.horizontalCenter: parent.horizontalCenter
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
                text: "\udb80\udfd8" // nf-md-palette
                color: Theme.accent
                font.family: Theme.iconFont
                font.pixelSize: Theme.fontSize
            }

            Row {
                x: Theme.padding + glyph.width + Theme.gap
                height: Theme.pillHeight
                spacing: Theme.gap + 6
                opacity: root.fade

                Repeater {
                    model: [{
                        "key": "themes",
                        "label": "Themes"
                    }, {
                        "key": "walls",
                        "label": "Wallpapers"
                    }]

                    Text {
                        id: tab

                        required property var modelData
                        readonly property bool active: Picker.view === modelData.key

                        height: Theme.pillHeight
                        verticalAlignment: Text.AlignVCenter
                        text: modelData.label
                        color: active ? Theme.accent : Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                        font.bold: active

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Picker.view = tab.modelData.key
                        }

                    }

                }

            }

            // body: fixed width, centered, so the card's growth reveals it
            Item {
                id: body

                width: root.cardWidth - Theme.padding * 2
                height: root.bodyHeight
                x: (card.width - width) / 2
                y: Theme.pillHeight + Theme.padding
                opacity: root.fade
                enabled: root.popup.open

                ListView {
                    id: themeList

                    visible: Picker.view === "themes"
                    anchors.fill: parent
                    spacing: root.rowGap
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: Themes.themes

                    delegate: Rectangle {
                        id: row

                        required property var modelData
                        required property int index
                        readonly property bool picked: index === root.ti

                        width: ListView.view.width
                        height: root.rowHeight
                        radius: Theme.radiusSmall
                        color: picked ? Theme.surfaceAlt : "transparent"
                        border.width: 1
                        border.color: picked ? Theme.accent : "transparent"

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.padding
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.name
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                        }

                        Text {
                            anchors.right: swatches.left
                            anchors.rightMargin: Theme.gap
                            anchors.verticalCenter: parent.verticalCenter
                            visible: row.modelData.slug === Themes.current
                            text: "\udb80\udd2c" // nf-md-check
                            color: Theme.ok
                            font.family: Theme.iconFont
                            font.pixelSize: Theme.fontSmall
                        }

                        Row {
                            id: swatches

                            anchors.right: parent.right
                            anchors.rightMargin: Theme.padding
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Repeater {
                                model: row.modelData.swatches

                                Rectangle {
                                    required property string modelData

                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: modelData
                                    border.width: 1
                                    border.color: Theme.border
                                }

                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: root.ti = row.index
                            onClicked: {
                                root.ti = row.index;
                                root.activate();
                            }
                        }

                    }

                }

                ListView {
                    id: wallList

                    visible: Picker.view === "walls"
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    spacing: 8
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: Themes.wallpapers

                    // vertical wheel scrolls the strip sideways
                    WheelHandler {
                        onWheel: (event) => {
                            wallList.contentX = Math.max(0, Math.min(wallList.contentWidth - wallList.width, wallList.contentX - event.angleDelta.y));
                        }
                    }

                    delegate: Rectangle {
                        id: cell

                        required property var modelData
                        required property int index
                        readonly property bool picked: index === root.wi
                        readonly property bool isCurrent: modelData.path === Themes.currentWall

                        width: root.thumbW
                        height: root.thumbH
                        color: "transparent"

                        Image {
                            anchors.fill: parent
                            source: "file://" + cell.modelData.thumb
                            sourceSize.width: 320
                            sourceSize.height: 180
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                        }

                        // border on top so the rounded thumb fills the whole cell
                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusSmall
                            color: "transparent"
                            border.width: 2
                            border.color: cell.picked ? Theme.accent : cell.isCurrent ? Theme.ok : Theme.border
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: root.wi = cell.index
                            onClicked: {
                                root.wi = cell.index;
                                root.activate();
                            }
                        }

                    }

                }

                Text {
                    anchors.centerIn: parent
                    visible: Picker.view === "walls" && Themes.wallpapers.length === 0
                    text: Themes.loadingWalls ? "Generating thumbnails…" : Themes.current === "" ? "Apply a theme first" : "No wallpapers"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
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
