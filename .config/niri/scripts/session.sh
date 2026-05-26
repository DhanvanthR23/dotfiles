#!/usr/bin/env bash
# ~/.config/niri/scripts/session.sh
# Session menu via fuzzel dmenu — Tokyo Night Storm
# Bound to Ctrl+Alt+Delete in niri config

chosen=$(printf "  Lock\n  Logout\n󰒲  Suspend\n  Reboot\n  Shutdown" |
  fuzzel --dmenu \
    --placeholder "session..." \
    --lines 5 \
    --width 20 \
    --anchor top)

case "$chosen" in
"  Lock")
  ~/.config/niri/scripts/lock.sh
  ;;
"  Logout")
  niri msg action quit --skip-confirmation
  ;;
"󰒲  Suspend")
  systemctl suspend
  ;;
"  Reboot")
  systemctl reboot
  ;;
"  Shutdown")
  systemctl poweroff
  ;;
esac
