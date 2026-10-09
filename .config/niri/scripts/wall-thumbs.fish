#!/usr/bin/env fish
# usage: wall-thumbs.fish <wallpaper-dir>
# writes 320x180 jpg thumbs to ~/.cache/qs-test/thumbs/<dirname>/<file>.jpg (only missing/outdated ones)
set -l src $argv[1]
set -l cache_home ~/.cache
set -q XDG_CACHE_HOME; and set cache_home $XDG_CACHE_HOME
set -l out $cache_home/qs-test/thumbs/(basename $src)
mkdir -p $out

set -l tool
if command -sq magick
    set tool magick
else if command -sq convert
    set tool convert
else
    echo "need imagemagick" >&2
    exit 1
end

for f in (find -L $src -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \))
    set -l t $out/(basename $f).png
    if not test -f $t; or test $f -nt $t
        $tool -define jpeg:size=640x360 $f -auto-orient -thumbnail 320x180^ -gravity center -extent 320x180 -alpha set \( -size 320x180 xc:none -fill white -draw "roundrectangle 0,0 319,179 20,20" \) -compose DstIn -composite $t
    end
end
