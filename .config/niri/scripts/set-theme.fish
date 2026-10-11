#!/usr/bin/env fish
# usage: set-theme.fish <slug> [wallpaper-file | --keep]
# slug = file name in ~/.config/colors/themes (without .conf)
set -l cfg ~/.config/colors
set -l walls ~/Pictures/wallpapers
set -l state_home ~/.local/state
set -q XDG_STATE_HOME; and set state_home $XDG_STATE_HOME
set -l state $state_home/qs-test

set -l slug $argv[1]
set -l theme $cfg/themes/$slug.conf
if not test -f $theme
    echo "no such theme: $slug" >&2
    exit 1
end

# theme slug -> wallpaper folder
set -l dir (fish (status dirname)/wall-dir.fish $slug)
switch $slug
    case rose-pine-moon
        set dir rose-pine
    case nord
        set dir nord
    case catppuccin-mocha
        set dir catppuccin-mocha
    case gruvbox-dark
        set dir gruvbox-dark
    case kanagawa
        set dir kanagawa
    case one-dark
        set dir one-dark
end

# colors: copy + propagate
mkdir -p $state ~/.config/gtk-3.0 ~/.config/gtk-4.0
cp $theme $cfg/colors.conf
bash ~/.config/niri/scripts/generate-colors.sh >/dev/null; or echo "generate-colors.sh failed" >&2
qs ipc call theme reload 2>/dev/null
echo $slug >$state/theme
thunar -q 2>/dev/null
setsid thunar --daemon >/dev/null 2>&1 &

# wallpaper
set -l pick $argv[2]
if test "$pick" = --keep
    exit 0
end
if test -z "$pick"
    set pick (find -L $walls/$dir -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n1)
end
if test -z "$pick"
    echo "no wallpapers in $walls/$dir" >&2
    exit 0
end
pgrep -x awww-daemon >/dev/null; or begin
    setsid awww-daemon >/dev/null 2>&1 &
    sleep 0.5
end
awww img $pick --transition-type fade --transition-duration 1
echo $pick >$state/wallpaper
