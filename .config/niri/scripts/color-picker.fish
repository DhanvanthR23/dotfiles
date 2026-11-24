#!/usr/bin/env fish

set output (niri msg pick-color 2>/dev/null)
set hex (string match -r '#[0-9a-fA-F]{6}' -- $output)

if test -n "$hex"
    printf '%s' (string upper $hex) | wl-copy
    echo "Copied $hex"
else
    echo "Failed to capture colour" >&2
    exit 1
end
