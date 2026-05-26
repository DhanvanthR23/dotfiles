#!/usr/bin/env bash
# ~/.config/niri/scripts/run-update.sh

CACHE="$XDG_RUNTIME_DIR/waybar-updates.cache"
rm -f "$CACHE"

foot -e bash -c "paru -Syu --sudoloop; echo ''; echo '  Done. Press any key to close.'; read -n1" &
