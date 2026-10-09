#!/usr/bin/env bash
# usage: update-count.sh [--force]
cache="${XDG_CACHE_HOME:-$HOME/.cache}/qs-test/update-count"
ttl=1500   # seconds, a bit under the 30 min timer so the timer always refreshes

# fresh cache -> print and bail
if [[ $1 != --force && -f $cache ]]; then
  age=$(( $(date +%s) - $(stat -c %Y "$cache") ))
  if (( age < ttl )); then
    cat "$cache"
    exit 0
  fi
fi

# checkupdates: exit 0 = updates, 2 = none, 1 = real error (offline etc)
out=$(checkupdates 2>/dev/null); rc=$?
if (( rc == 1 )); then
  # offline or broken: keep the old cache if any, never cache a fake 0
  [[ -f $cache ]] && cat "$cache" || echo 0
  exit 0
fi
official=$(printf '%s' "$out" | grep -c .)

if command -v paru &>/dev/null; then
  aur=$(paru -Qua 2>/dev/null | wc -l)
elif command -v yay &>/dev/null; then
  aur=$(yay -Qua 2>/dev/null | wc -l)
else
  aur=0
fi

total=$(( official + aur ))
mkdir -p "$(dirname "$cache")"
echo "$total" > "$cache.tmp" && mv "$cache.tmp" "$cache"   # atomic write
echo "$total"
