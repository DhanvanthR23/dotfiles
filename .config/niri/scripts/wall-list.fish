#!/usr/bin/env fish
# usage: wall-list.fish <theme-slug>
# makes missing thumbs, then prints "<wallpaper>\t<thumb>" per line
set -l slug $argv[1]
set -l walls ~/Pictures/wallpapers

# theme slug -> wallpaper folder (same mapping as set-theme.fish)
set -l dir $slug
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

set -l src $walls/$dir
test -d $src; or exit 0
set -l here (status dirname)
$here/wall-thumbs.fish $src

set -l cache_home ~/.cache
set -q XDG_CACHE_HOME; and set cache_home $XDG_CACHE_HOME
for f in (find -L $src -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)
    printf '%s\t%s\n' $f $cache_home/qs-test/thumbs/$dir/(basename $f).png
end
