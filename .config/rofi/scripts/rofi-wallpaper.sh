#!/usr/bin/env bash

set -Eeuo pipefail

THEME="$HOME/.config/rofi/launchers/type-3/style-4.rasi"
DIR="$HOME/Pictures/wallpapers/favorites"
SELECTED_WALL=$(cd "$DIR" && for a in *.jpg *.png; do echo -en "$a\0icon\x1f$a\n"; done | rofi -dmenu -i -no-custom -theme "$THEME" -p "Select a wallpaper" -theme-str 'configuration {icon-size: 128; dpi: 96;} window {width: 45%; height: 45%;}')
PTH="$(printf "%s" "$DIR/$SELECTED_WALL" | tr -s '/')"
hyprctl hyprpaper preload "$PTH"
hyprctl hyprpaper wallpaper "$PTH"
hyprctl hyprpaper unload "$(cat "$HOME/.wallpaper")"
# hyprctl hyprpaper wallpaper "DP-1, $PTH"
notify-send -a "rofi-wallpaper" "Wallpaper set to" -i "$PTH" "$PTH"
echo "$PTH" >"$HOME/.wallpaper"
