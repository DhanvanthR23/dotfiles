import "../../config"
import "../../services"
import QtQuick
import Quickshell

Scope {
    id: root

    required property var screen
    required property var pill
    readonly property bool open: Lock.open
    readonly property bool hasKeyboard: Lock.screenName === screen.name
    property real progress: open ? 1 : 0

    LazyLoader {
        active: root.open || root.progress > 0

        LockOverlay {
            popup: root
            screen: root.screen
        }
    }

    Behavior on progress {
        NumberAnimation {
            duration: root.open ? 450 : 750
            easing.type: root.open ? Easing.OutCubic : Easing.InOutCubic
        }
    }
}
