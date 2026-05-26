#!/usr/bin/env bash
sink_desc=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep 'node.description' | grep -oP '(?<=")[^"]+(?=")')

case "$sink_desc" in
*"Speaker"* | *"Built-in"* | *"Internal"*)
  limit="1.53"
  ;;
*)
  limit="1.0"
  ;;
esac

wpctl set-volume "@DEFAULT_AUDIO_SINK@" "0.1+" --limit "$limit"
