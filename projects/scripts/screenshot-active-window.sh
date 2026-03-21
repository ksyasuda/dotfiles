#!/usr/bin/env bash

save_to_disk=false
while getopts "s" opt; do
	case $opt in
		s) save_to_disk=true ;;
		*) echo "Usage: $0 [-s]" && exit 1 ;;
	esac
done

tmpfile=$(mktemp /tmp/screenshot-XXXXXX.png)
grim -g "$(hyprctl activewindow -j | jq -r '.at[0],.at[1],.size[0],.size[1]' | tr '\n' ' ' | awk '{print $1","$2" "$3"x"$4}')" "$tmpfile"

if $save_to_disk; then
	savepath=$(zenity --file-selection --save --confirm-overwrite --title="Save Screenshot" --filename="screenshot.png" --file-filter="PNG files|*.png")
	if [[ -n "$savepath" ]]; then
		cp "$tmpfile" "$savepath"
		notify-send -i "$savepath" "Screenshot saved to $savepath"
	else
		notify-send "Screenshot save cancelled"
	fi
else
	wl-copy < "$tmpfile"
	notify-send -i "$tmpfile" "Screenshot of active window copied to clipboard"
fi

rm -f "$tmpfile"
