import "../../services"
import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    WlSessionLock {
        locked: Lock.secure

        WlSessionLockSurface {
            color: "black"

            LockFace {
                anchors.fill: parent
            }

            TextInput {
                id: input

                width: 1
                height: 1
                opacity: 0
                focus: true
                echoMode: TextInput.Password
                Component.onCompleted: forceActiveFocus()
                Keys.onEscapePressed: text = ""
                Keys.onPressed: (e) => {
                    if (e.key === Qt.Key_Backspace && (e.modifiers & Qt.ControlModifier)) {
                        text = "";
                        e.accepted = true;
                    }
                }
                onTextChanged: Lock.password = text
                onAccepted: Lock.attempt(text)
            }

            Connections {
                target: Lock

                function onWrong() {
                    input.text = "";
                }
            }
        }
    }
}
