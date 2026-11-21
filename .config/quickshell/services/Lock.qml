import QtQuick
import Quickshell
import Quickshell.Services.Pam
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool open: false
    property string screenName: ""
    property string password: ""
    property bool busy: false
    property string pending: ""
    property bool secure: false // drives the real session lock
    property string wallpaper: ""

    function loadWall() {
        wallFile.reload();
        wallpaper = wallFile.text().trim();
    }

    // animated: overlay plays first, the real lock engages when it settles
    property bool engaging: false

    function lockNow() {
        if (secure)
            return;
        Quickshell.execDetached(["playerctl", "pause"]);
        loadWall();
        show("");
        engaging = true;
    }

    function overlayDone() {
        if (engaging && open) {
            engaging = false;
            engage.start();
        }
    }

    // no animation: used for idle / sleep
    function lockInstant() {
        if (secure)
            return;
        Quickshell.execDetached(["playerctl", "pause"]);
        loadWall();
        secure = true;
    }

    Timer {
        id: engage

        interval: 300 // a bit more than the 450 ms open animation
        onTriggered: {
            if (root.open)
                root.secure = true;
        }
    }

    FileView {
        id: wallFile

        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/qs-test/wallpaper"
        blockLoading: true
        printErrors: false
    }

    signal wrong()

    function show(name) {
        loadWall();
        screenName = name || Picker.focusedOutput();
        open = true;
    }

    function hide() {
        engage.stop();
        open = false;
        password = "";
        pending = "";
        busy = false;
        secure = false;
    }

    function toggle(name) {
        if (open)
            hide();
        else
            show(name);
    }

    function attempt(pw) {
        if (busy || pw === "" || pam.active)
            return;
        busy = true;
        pending = pw;
        pam.start();
    }

    PamContext {
        id: pam

        config: "password.conf"
        configDirectory: Quickshell.env("HOME") + "/.config/quickshell/pam"

        onPamMessage: {
            if (responseRequired) {
                respond(root.pending);
                root.pending = ""; // don't keep the password around
            }
        }
        onCompleted: (result) => {
            root.busy = false;
            if (result === PamResult.Success)
                root.hide();
            else
                root.wrong();
        }
        onError: (err) => {
            root.busy = false;
            root.wrong();
        }
    }
}
