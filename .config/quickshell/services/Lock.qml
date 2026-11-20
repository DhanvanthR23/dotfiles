import QtQuick
import Quickshell
import Quickshell.Services.Pam
pragma Singleton

Singleton {
    id: root

    property bool open: false
    property string screenName: ""
    property string password: ""
    property bool busy: false
    property string pending: ""

    signal wrong()

    function show(name) {
        screenName = name || Picker.focusedOutput();
        open = true;
    }

    function hide() {
        open = false;
        password = "";
        pending = "";
        busy = false;
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
