#!/usr/bin/env bash
# ~/.config/niri/scripts/check-updates.sh

CACHE="$XDG_RUNTIME_DIR/waybar-updates.cache"
LOCK="$XDG_RUNTIME_DIR/waybar-updates.lock"

# stale lock guard — remove if older than 5 minutes
if [ -e "$LOCK" ]; then
  lock_age=$(($(date +%s) - $(stat -c %Y "$LOCK")))
  if [ "$lock_age" -lt 300 ]; then
    cat "$CACHE" 2>/dev/null || echo '{"text": "", "tooltip": "", "class": "updated"}'
    exit 0
  else
    rm -f "$LOCK"
  fi
fi

touch "$LOCK"
cleanup() { rm -f "$LOCK"; }
trap cleanup EXIT

notify-send -i system-software-update -t 3000 "Updates" "Checking for updates..."

fetch_count() {
  local official aur
  official=$(checkupdates 2>/dev/null | wc -l)
  if command -v paru &>/dev/null; then
    aur=$(paru -Qua 2>/dev/null | wc -l)
  elif command -v yay &>/dev/null; then
    aur=$(yay -Qua 2>/dev/null | wc -l)
  else
    aur=0
  fi
  echo $((official + aur))
}

count=$(fetch_count)

if [ "$count" -eq 0 ]; then
  notify-send -i system-software-update -t 4000 "Updates" "System is up to date"
  result='{"text": "", "tooltip": "System up to date", "class": "updated"}'
elif [ "$count" -ge 50 ]; then
  notify-send -u critical -i system-software-update -t 5000 "Updates" "$count updates available"
  result="{\"text\": \"󰚰 $count\", \"tooltip\": \"$count updates available\", \"class\": \"critical\"}"
elif [ "$count" -ge 10 ]; then
  notify-send -u normal -i system-software-update -t 5000 "Updates" "$count updates available"
  result="{\"text\": \"󰚰 $count\", \"tooltip\": \"$count updates available\", \"class\": \"warning\"}"
else
  notify-send -u low -i system-software-update -t 5000 "Updates" "$count updates available"
  result="{\"text\": \"󰚰 $count\", \"tooltip\": \"$count updates available\", \"class\": \"normal\"}"
fi

echo "$result" >"$CACHE"
echo "$result"
