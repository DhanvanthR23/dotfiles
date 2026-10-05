import QtQuick
import Quickshell
import Quickshell.Services.Mpris
pragma Singleton

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    // prefer whoever is playing, else the first player
    readonly property var player: players.find((p) => {
        return p.isPlaying;
    }) || players[0] || null
    readonly property bool available: player !== null
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player ? player.trackTitle : ""
    readonly property string artist: player ? player.trackArtist : ""
    readonly property string trackKey: title === "" ? "" : artist + " - " + title

    function toggle() {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player && player.canGoNext)
            player.next();
    }

    function previous() {
        if (player && player.canGoPrevious)
            player.previous();
    }

    // track change -> toast on the clock pill (only while actually playing)
    onTrackKeyChanged: {
        if (trackKey !== "" && playing)
            Notifs.show("Media", title, artist, 0, 3000);
    }
}
