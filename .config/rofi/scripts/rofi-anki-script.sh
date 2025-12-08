#!/usr/bin/env bash

CHOICES=(
    "1. Screenshot (Lapis)"
    "2. Screenshot (Luna)"
    "3. Record Audio"
)
CHOICE=$(printf "%s\n" "${CHOICES[@]}" | rofi -dmenu -i -theme "$HOME/.config/rofi/launchers/type-2/style-2.rasi" -theme-str 'window {width: 25%;} listview {columns: 1; lines: 5;}' -p "Select an option")

case "$CHOICE" in
"1. Screenshot (Lapis)")
    PICTURE_FIELD=Picture "$HOME/projects/scripts/screenshot-anki.sh"
    ;;
"2. Screenshot (Luna)")
    PICTURE_FIELD=screenshot "$HOME/projects/scripts/screenshot-anki.sh"
    ;;
"3. Record Audio")
    "$HOME/projects/scripts/record-audio.sh"
    ;;
*)
    exit 1
    ;;
esac

