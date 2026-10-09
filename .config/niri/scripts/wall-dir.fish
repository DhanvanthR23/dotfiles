#!/usr/bin/env fish
# usage: wall-dir.fish <theme-slug> -> prints the wallpaper folder name
switch $argv[1]
    case rose-pine-moon
        echo rose-pine
    case nord
        echo nordic-wallpapers
    case catppuccin-mocha
        echo walls-catppuccin-mocha
    case gruvbox-dark
        echo gruvbox-wallpapers
    case kanagawa
        echo Kanagawa-wallpapers
    case one-dark
        echo onedark-wallpapers
    case '*'
        echo $argv[1]
end
