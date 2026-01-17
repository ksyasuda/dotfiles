#!/usr/bin/env bash

PROGRAM="$HOME/S/lutris/wineprefix/drive_c/users/steamuser/luna-translator/LunaTranslator.exe"
SELECTION="$(protontricks -l | tail -n +2 | rofi -dmenu -theme ~/.config/rofi/launchers/type-2/style-2.rasi -theme-str 'listview {lines: 12; columns: 1;}' -i -p "Select game" | awk '{print $NF}' | tr -d '()')"

if [[ -z "$SELECTION" ]]; then
    printf "%s\n" "No game selected"
    exit 1
fi

printf "%s\n" "Launching $PROGRAM for game ID: $SELECTION"
protontricks-launch --appid "$SELECTION" "$PROGRAM" &>/dev/null &
