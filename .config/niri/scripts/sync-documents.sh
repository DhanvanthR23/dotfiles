#!/bin/bash
SRC="$HOME/Documents"
DEST="/mnt/storage/Documents"

mkdir -p "$DEST"

inotifywait -m -r -e close_write,create,moved_to --format '%w%f' "$SRC" | while read -r file; do
  rsync -av --relative "$SRC/./$(realpath --relative-to="$SRC" "$file")" "$DEST/"
done
