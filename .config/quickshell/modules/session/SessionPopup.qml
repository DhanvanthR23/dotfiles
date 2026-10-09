import "../../config"
import "../../services"
import QtQuick
import Quickshell

Scope {
    id: root

    required property var screen
    required property var pill
    readonly property bool open: Session.open && Session.screenName === screen.name
    property real progress: open ? 1 : 0

    // stays alive while shrinking
    LazyLoader {
        active: root.open || root.progress > 0

        SessionOverlay {
            popup: root
            screen: root.screen
        }

    }

    Behavior on progress {
        NumberAnimation {
            duration: Theme.animLauncher
            easing.type: Easing.OutCubic
        }

    }

}
