import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var popup

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: popup.open
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    // don't push windows around

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.popup.close()

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: root.popup.close()
        }

    }

}
