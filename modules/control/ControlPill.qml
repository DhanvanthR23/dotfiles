import Quickshell
import QtQuick
import QtQuick.Shapes
import "../../config"
import "../../services"

Rectangle {
    id: root

    readonly property bool hovered: hover.hovered

    readonly property real ringWidth: 2
    readonly property real fraction: Battery.available ? Battery.percent / 100 : 0
    readonly property color ringColor: Battery.low ? Theme.error
                                     : Battery.pluggedIn ? Theme.ok
                                     : Theme.accent

    readonly property string tipText:
        Net.label + (Battery.available
            ? "  ·  " + Math.round(Battery.percent) + "%"
              + (Battery.charging ? " charging" : Battery.pluggedIn ? " plugged in" : "")
            : "")

    property bool tipEnabled: true          // disabled while the popup is open
    property bool showTip: false
    signal clicked()

    onHoveredChanged: {
        if (hovered && tipEnabled) tipTimer.restart()
        else { tipTimer.stop(); showTip = false }
    }
    Timer { id: tipTimer; interval: 400; onTriggered: root.showTip = true }

    implicitWidth: Theme.pillHeight
    implicitHeight: Theme.pillHeight
    radius: width / 2
    color: hover.hovered ? Theme.surfaceAlt : Theme.surface

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // background track: the full circle
        ShapePath {
            strokeColor: Theme.border
            strokeWidth: root.ringWidth
            fillColor: "transparent"

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - root.ringWidth / 2
                radiusY: radiusX
                startAngle: -90
                sweepAngle: 360
            }
        }

        // battery progress: starts at 12 o'clock, sweeps clockwise
        ShapePath {
            strokeColor: root.ringColor
            strokeWidth: root.ringWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - root.ringWidth / 2
                radiusY: radiusX
                startAngle: -90
                sweepAngle: 360 * root.fraction
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: Net.icon
        color: Net.type === "wifi" || Net.type === "wired" ? Theme.text : Theme.textMuted
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.clicked() }
    PopupWindow {
        id: tip
        anchor.item: root
        anchor.rect.x: (root.width - width) / 2
        anchor.rect.y: root.height + 6

        implicitWidth: tipLabel.implicitWidth + Theme.padding * 2
        implicitHeight: Theme.pillHeight
        visible: root.showTip && root.tipEnabled
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            Text {
                id: tipLabel
                anchors.centerIn: parent
                text: root.tipText
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }
        }
    }
}
