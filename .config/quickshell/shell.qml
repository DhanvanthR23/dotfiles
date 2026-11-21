import "./modules/bar"
import "./modules/lock"
import "./services"
import Quickshell

Scope {
    readonly property var ipc: Ipc

    Bar {
    }
    LockSession { }
}
