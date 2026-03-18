#!/usr/bin/env bash

window_info=$(hyprctl activewindow -j)
read -r is_pinned window_class window_title <<< "$(echo "$window_info" | jq -r '[.pinned, .class, .title] | @tsv')"

hyprctl dispatch pin active

read -r window_x window_y window_w window_h <<< "$(echo "$window_info" | jq -r '[.at[0], .at[1], .size[0], .size[1]] | @tsv')"

screenshot=$(mktemp --suffix=.png)
grim -g "${window_x},${window_y} ${window_w}x${window_h}" "$screenshot"

if [ "$is_pinned" = "true" ]; then
	status="Unpinned"
else
	status="Pinned"
fi

notify-send -u low -i "$screenshot" "$status: $window_class" "$window_title"
rm -f "$screenshot"

# vim: set ft=sh
