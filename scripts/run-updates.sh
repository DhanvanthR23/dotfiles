#!/usr/bin/env bash
# ~/.config/niri/scripts/run-update.sh

foot -e bash -c "paru -Syu --sudoloop; echo ''; echo '  Done. Press any key to close.'; read -n1" &
