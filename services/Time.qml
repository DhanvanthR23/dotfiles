import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm")
    readonly property date now: clock.date
    readonly property string dateShort: Qt.formatDate(clock.date, "dddd d MMMM")

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

}
