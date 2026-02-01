#!/usr/bin/env bash

set -Eeuo pipefail

THEME="$HOME/.config/rofi/launchers/type-3/style-4.rasi"
DIR="$HOME/Pictures/wallpapers/favorites"
SELECTED_WALL=$(cd "$DIR" && for a in *.jpg *.png; do echo -en "$a\0icon\x1f$a\n"; done | rofi -dmenu -i -no-custom -theme "$THEME" -p "Select a wallpaper" -theme-str 'configuration {icon-size: 256; dpi: 96;} window {width: 75%; height: 69%;} listview {rows: 5; lines: 7;}')
PTH="$(printf "%s" "$DIR/$SELECTED_WALL" | tr -s '/')"
hyprctl hyprpaper wallpaper "DP-1, $PTH"
notify-send -a "rofi-wallpaper" "Wallpaper set to" -i "$PTH" "$PTH"
echo "$PTH" >"$HOME/.wallpaper"
