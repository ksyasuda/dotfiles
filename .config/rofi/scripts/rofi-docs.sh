#!/usr/bin/env bash

BROWSER=/usr/bin/zen-browser
URLS=(
    "Archlinux Wiki|https://wiki.archlinux.org/title/Main_page"
    "Hyprland Docs|https://wiki.hypr.land/"
    "Hyprland Window Rules|https://wiki.hypr.land/Configuring/Window-Rules/"
)

DISPLAY_URLS=()
declare -A URL_MAP
for url in "${URLS[@]}"; do
    DISPLAY_URLS+=("${url%%|*}")
    label="${url%%|*}"
    URL_MAP["$label"]="${url##*|}"
done

SELECTION="$(printf "%s\n" "${DISPLAY_URLS[@]}" | rofi -theme-str 'window {width: 25%;} listview {columns: 1; lines: 10;}' -theme ~/.config/rofi/launchers/type-2/style-2.rasi -dmenu -l 5 -i -p "Select Documentation")"
URL="${URL_MAP[$SELECTION]}"
$BROWSER "$URL" &>/dev/null &
