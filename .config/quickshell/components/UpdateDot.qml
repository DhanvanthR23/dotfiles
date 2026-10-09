import "../config"
import "../services"
import QtQuick

Rectangle {
    width: 8
    height: 8
    radius: 4
    visible: Updates.count > 0
    color: Updates.level === "critical" ? Theme.error : Updates.level === "warning" ? Theme.warn : Theme.accent

    TapHandler {
        margin: 6
        onTapped: Updates.run()
    }

}
