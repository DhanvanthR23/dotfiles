import "../../config"
import "../../services"
import QtQuick
import Quickshell

Scope {
    id: root

    required property var screen
    required property Item pill
    property bool open: false
    property real startX: 0 // screen x of the pill when it was clicked
    property real progress: open ? 1 : 0
    // first half: travel to center, second half: expand

    function smooth(t) {
        const c = Math.max(0, Math.min(1, t));
        return c * c * (3 - 2 * c); // smoothstep: zero speed at both ends
    }

    readonly property real travel: smooth(progress / 0.65)
    readonly property real fade: smooth((progress - 0.35) / 0.65)



    function toggle() {
        if (!open)
            startX = Theme.gap + pill.mapToItem(null, 0, 0).x; // bar window sits Theme.gap from the screen edge
        open = !open;
    }

    function close() {
        open = false;
    }

    onOpenChanged: {
        if (!open)
            Launcher.reset();
    }

    Behavior on progress {
        NumberAnimation {
            duration: root.open ? Theme.animLauncher : Theme.animLauncherClose
            easing.type: Easing.Linear
        }
    }

    // stays alive while shrinking
    LazyLoader {
        active: root.open || root.progress > 0

        LauncherOverlay {
            popup: root
            screen: root.screen
        }
    }
}
