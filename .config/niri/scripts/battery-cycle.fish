#!/usr/bin/env fish

set current (powerprofilesctl get)

switch $current
    case performance
        set next balanced
    case balanced
        set next power-saver
    case power-saver
        set next performance
    case '*'
        set next balanced
end

powerprofilesctl set $next

switch $next
    case performance
        notify-send -i battery -u normal "Power Profile" "⚡ Performance" -t 1500
    case balanced
        notify-send -i battery -u normal "Power Profile" "⚖️ Balanced" -t 1500
    case power-saver
        notify-send -i battery -u normal "Power Profile" "🔋 Power Saver" -t 1500
end
