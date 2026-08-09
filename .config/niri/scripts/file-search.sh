#!/usr/bin/env bash
# ~/.config/niri/scripts/file-search.sh
# Fuzzy file search with fd + fuzzel. Bound to Mod+Shift+D in niri config.
# Respects ~/.fdignore and hidden files are excluded by default.

set -euo pipefail

pkill -x fuzzel && exit 0

target="${1:-$HOME}"

file=$(fd --type f . "$target" --color never | awk -F/ '{print $NF "\t" $0}' | fuzzel --dmenu \
  --placeholder "search files" \
  --lines 10 \
  --width 55 \
  --anchor center \
  --with-nth=1 \
  --match-nth=2 \
  --accept-nth=2 \
  --no-run-if-empty)

[ -z "$file" ] && exit 0

xdg-open "$file" >/dev/null 2>&1 &
