#!/bin/sh
# ~/.config/mango/screenshot.sh
# Usage: screenshot.sh [region|screen|monitor]
# Deps: grim, slurp, satty, wl-copy

set -e

SAVEDIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVEDIR"
OUTFILE="$SAVEDIR/Screenshot from $(date +"%Y-%m-%d %H-%M-%S").png"

case "$1" in
region)
  # Direct save + copy, no annotation
  grim -g "$(slurp -d)" "$OUTFILE" && wl-copy <"$OUTFILE"
  ;;
region-annotate)
  grim -t ppm -g "$(slurp -d)" - |
    satty --filename - \
      --copy-command wl-copy \
      --output-filename "$OUTFILE" \
      --actions-on-escape save-to-clipboard,exit
  pkill -x satty 2>/dev/null || true
  ;;
screen)
  grim -t ppm - |
    satty --filename - \
      --copy-command wl-copy \
      --output-filename "$OUTFILE" \
      --actions-on-escape save-to-clipboard,exit
  pkill -x satty 2>/dev/null || true
  ;;
monitor)
  # Click a monitor to capture it, or draw a box for a region
  grim -t ppm -g "$(slurp -o -d)" - |
    satty --filename - \
      --copy-command wl-copy \
      --output-filename "$OUTFILE" \
      --actions-on-escape save-to-clipboard,exit
  pkill -x satty 2>/dev/null || true
  ;;
*)
  echo "Usage: $0 [region|screen|monitor]"
  exit 1
  ;;
esac
