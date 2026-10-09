import "../config"
import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property bool active: false
    property bool dndBefore: false

    onActiveChanged: {
        Theme.reduceMotion = active;
        if (active) {
            dndBefore = Notifs.dnd; // remember what DND was
            Notifs.dnd = true;
        } else {
            Notifs.dnd = dndBefore; // put it back
        }
    }
}
