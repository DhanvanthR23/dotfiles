pragma Singleton

import Quickshell
import QtQuick

Singleton{
    id: root
    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm")
    readonly property string date: Qt.formatDate(clock.date, "dddd d MMMM yyyy")
    SystemClock{
        id: clock
        precision: SystemClock.Minutes
    }
}
