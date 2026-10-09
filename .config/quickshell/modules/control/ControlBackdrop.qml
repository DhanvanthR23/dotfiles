import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    signal dismissed()

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.dismissed()

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: root.dismissed()
        }

    }

}
