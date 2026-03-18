#!/usr/bin/env bash

tmpfile=$(mktemp /tmp/screenshot-XXXXXX.png)
grim -g "$(hyprctl activewindow -j | jq -r '.at[0],.at[1],.size[0],.size[1]' | tr '\n' ' ' | awk '{print $1","$2" "$3"x"$4}')" "$tmpfile"
wl-copy < "$tmpfile"
notify-send -i "$tmpfile" "Screenshot of active window copied to clipboard"
rm -f "$tmpfile"
