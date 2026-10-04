import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root
    required property var popup

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore   // don't push windows around
    color: "transparent"
    visible: popup.open

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

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
