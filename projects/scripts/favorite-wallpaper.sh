#!/bin/bash

HOME=/home/$USER

CURRENT="$(cat ~/.wallpaper)"
CURRENT="${CURRENT/\/\///}"
OUTPUT_DIR="/truenas/sudacode/pictures/wallpapers/"

cp "$CURRENT" "$HOME/Pictures/wallpapers/favorites/"

if cp "$CURRENT" "$OUTPUT_DIR"; then
    notify-send "favorite-wallpaper" "Wallpaper saved to $OUTPUT_DIR"
else
    notify-send "favorite-wallpaper" "Failed to saved wallpaper to $OUTPUT_DIR"
fi

# ft: sh
