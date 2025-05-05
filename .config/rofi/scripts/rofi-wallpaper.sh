#!/usr/bin/env bash

set -Eeuo pipefail

THEME="$HOME/.config/rofi/launchers/type-3/style-4.rasi"
DIR="$HOME/Pictures/wallpapers/wallhaven"
SELECTED_WALL=$(cd "$DIR" && for a in *.jpg *.png; do echo -en "$a\0icon\x1f$a\n"; done | rofi -dmenu -theme "$THEME" -p "Select a wallpaper" -theme-str 'configuration {icon-size: 128; dpi: 96;} window {width: 45%; height: 45%;}')

notify-send -a "rofi-wallpaper" "Wallpaper set to" -i "$DIR/$SELECTED_WALL" "$DIR/$SELECTED_WALL"
hyprctl hyprpaper reload , "$DIR/$SELECTED_WALL"
