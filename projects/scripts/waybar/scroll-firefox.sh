#!/bin/sh

zscroll -p ' | ' --delay 0.2 \
	--length 30 \
	--match-command "$HOME/.config/waybar/scripts/playerctl.sh firefox" \
	--match-text ' ' "" \
	--match-text ' ' "--scroll 0" \
	--match-text "^volume:" "--before-text '' --scroll 0 --after-text ''" \
	--update-interval 1 \
	--update-check true "$HOME/.config/waybar/scripts/playerctl.sh firefox" &
wait
