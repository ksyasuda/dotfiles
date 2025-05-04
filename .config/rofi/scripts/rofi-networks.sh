#!/usr/bin/env bash

[ $# -gt 0 ] && ROFI_CONFIG="$1" || ROFI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"
choice=$(rofi -dmenu -config "$ROFI_CONFIG" -sep '|' -i -l 2 -p "Enter choice:" <<< "1. Pihole Mode|2. Normal Mode|3. Work Mode|4. Quit")
[ ! "$choice" ] && exit 1
selection=$(awk '{print $1}' <<< "$choice")
case "$selection" in
	1.)
		systemctl --user start end-work-wallpaper.service
		systemctl --user start end-work-network.service
		;;
	2.)
		systemctl --user start end-work-wallpaper.service
		systemctl --user start start-work-network.service
		/home/sudacode/Work/scripts/vpn n
		;;
	3.)
		systemctl --user start start-work-wallpaper.service
		systemctl --user start start-work-network.service
		/home/sudacode/Work/scripts/vpn c
		;;
	4.)
		exit 0
		;;
	*)
		exit 1
		;;
esac
# choice=$(rofi -dmenu -config "$ROFI_CONFIG" -i -l 6 -p "Choose Network" < <(nmcli c | awk '!/^(br|virbr|docker)/' | tail -n +2))
# [ ! "$choice" ] && exit 1
# name=$(awk '{ print $1; }' <<< "$choice")
# if nmcli c show --active | grep -q "$name"; then
# 	nmcli c down "$name" &> /dev/null &
# else
# 	nmcli c up "$name" &> /dev/null &
# fi
