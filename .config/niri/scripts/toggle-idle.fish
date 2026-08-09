#!/usr/bin/env fish
set lockfile /tmp/hypridle_disabled

if test -f $lockfile
    rm $lockfile
    pkill hypridle
    hypridle &
    disown
    notify-send hypridle enabled
else
    touch $lockfile
    pkill hypridle
    notify-send hypridle disabled
end
