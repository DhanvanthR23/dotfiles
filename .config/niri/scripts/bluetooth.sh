#!/usr/bin/env bash
# ~/.config/niri/scripts/bluetooth.sh
# Emits waybar custom module JSON. Empty text = module auto-collapses (see style.css).
# Call modes:
#   bluetooth.sh          -> print current state (used by waybar "exec")
#   bluetooth.sh watch     -> daemon mode, blocks and signals waybar on change

set -euo pipefail

state() {
    if ! command -v bluetoothctl >/dev/null; then
        echo '{"text":"","tooltip":"","class":"hidden"}'
        return
    fi

    powered=$(bluetoothctl show | grep -q "Powered: yes" && echo 1 || echo 0)
    if [ "$powered" -eq 0 ]; then
        echo '{"text":"","tooltip":"Bluetooth off","class":"hidden"}'
        return
    fi

    # Grab connected device MACs
    mapfile -t devices < <(bluetoothctl devices Connected | awk '{print $2}')

    if [ "${#devices[@]}" -eq 0 ]; then
        # Powered but nothing connected -> collapse (autohide)
        echo '{"text":"","tooltip":"","class":"hidden"}'
        return
    fi

    names=()
    tooltip_lines=()
    for mac in "${devices[@]}"; do
        info=$(bluetoothctl info "$mac")
        name=$(echo "$info" | awk -F': ' '/Name:/{print $2; exit}')
        [ -z "$name" ] && name="$mac"
        batt=$(echo "$info" | awk -F'[()]' '/Battery Percentage/{print $2; exit}')
        if [ -n "$batt" ]; then
            tooltip_lines+=("${name} — ${batt}%")
        else
            tooltip_lines+=("${name} — battery n/a")
        fi
        names+=("$name")
    done

    if [ "${#devices[@]}" -eq 1 ]; then
        text="󰂱 ${names[0]}"
    else
        text="󰂱 ${#devices[@]} devices"
    fi

    # Build tooltip with \n-joined lines, escaped for JSON
    tooltip=$(printf '%s\\n' "${tooltip_lines[@]}")
    tooltip="${tooltip%\\n}"

    printf '{"text":"%s","tooltip":"%s","class":"connected"}\n' "$text" "$tooltip"
}

if [ "${1:-}" = "watch" ]; then
    state
    bluetoothctl --monitor 2>/dev/null | while read -r _; do
        state
        pkill -RTMIN+9 waybar 2>/dev/null || true
    done
else
    state
fi
