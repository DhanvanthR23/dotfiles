import "../config"
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool ready: false
    property real temp: 0
    property real feels: 0
    property real high: 0
    property real low: 0
    property int code: 0
    property bool isDay: true
    readonly property string condition: describe(code)
    readonly property string icon: iconFor(code, isDay)
    readonly property string url: "https://api.open-meteo.com/v1/forecast?latitude=" + Settings.latitude + "&longitude=" + Settings.longitude + "&current=temperature_2m,apparent_temperature,weather_code,is_day&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=1"

    function describe(c) {
        if (c === 0)
            return "Clear";
        if (c <= 2)
            return "Partly cloudy";
        if (c === 3)
            return "Overcast";
        if (c === 45 || c === 48)
            return "Fog";
        if (c >= 51 && c <= 57)
            return "Drizzle";
        if (c >= 61 && c <= 67)
            return "Rain";
        if (c >= 71 && c <= 77)
            return "Snow";
        if (c >= 80 && c <= 82)
            return "Showers";
        if (c === 85 || c === 86)
            return "Snow showers";
        if (c >= 95)
            return "Thunderstorm";
        return "Unknown";
    }

    function iconFor(c, day) {
        if (c === 0)
            return day ? "\udb81\udd99" : "\udb81\udd94"; // sunny / night
        if (c <= 2)
            return day ? "\udb81\udd95" : "\udb83\udf31"; // partly cloudy
        if (c === 3)
            return "\udb81\udd90"; // cloudy
        if (c === 45 || c === 48)
            return "\udb81\udd91"; // fog
        if (c >= 51 && c <= 61 || c === 80)
            return "\udb81\udd97"; // rainy
        if (c >= 63 && c <= 67 || c === 81 || c === 82)
            return "\udb81\udd96"; // pouring
        if (c >= 71 && c <= 77 || c === 85 || c === 86)
            return "\udb81\udd98"; // snowy
        if (c >= 95)
            return "\udb81\ude7e"; // lightning
        return "\udb81\udd90";
    }

    function refresh() {
        if (!fetcher.running)
            fetcher.running = true;
    }

    Process {
        id: fetcher

        command: ["curl", "-sf", "--max-time", "10", root.url]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(this.text);
                    root.temp = j.current.temperature_2m;
                    root.feels = j.current.apparent_temperature;
                    root.code = j.current.weather_code;
                    root.isDay = j.current.is_day === 1;
                    root.high = j.daily.temperature_2m_max[0];
                    root.low = j.daily.temperature_2m_min[0];
                    root.ready = true;
                } catch (e) {
                    // offline or bad reply: keep the last good data
                }
            }
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
