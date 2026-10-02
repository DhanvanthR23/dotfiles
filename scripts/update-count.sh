#!/usr/bin/env bash
official=$(checkupdates 2>/dev/null | wc -l)
if command -v paru &>/dev/null; then
  aur=$(paru -Qua 2>/dev/null | wc -l)
elif command -v yay &>/dev/null; then
  aur=$(yay -Qua 2>/dev/null | wc -l)
else
  aur=0
fi
echo $((official + aur))
