#!/usr/bin/env fish
set target $argv[1]
set function $argv[2]

if test -z "$target"; or test -z "$function"
    echo "Usage: quickshell-launcher.fish <target> <function>"
    exit 1
end

qs ipc call $target $function
