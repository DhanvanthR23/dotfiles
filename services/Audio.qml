pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool hasSink: sink !== null && sink.audio !== null
    readonly property real volume: hasSink ? sink.audio.volume : 0
    readonly property bool muted: hasSink ? sink.audio.muted : false

    // PipeWire only keeps a node's properties live while something tracks it
    PwObjectTracker { objects: [root.sink] }

    readonly property string icon:
        muted || volume === 0 ? "󰝟"
        : volume < 0.34 ? "󰕿"
        : volume < 0.67 ? "󰖀"
        : "󰕾"

    function setVolume(v) {
        if (hasSink) sink.audio.volume = Math.max(0, Math.min(1, v))
    }
    function toggleMute() {
        if (hasSink) sink.audio.muted = !sink.audio.muted
    }
}
