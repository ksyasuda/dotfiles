#!/bin/bash

zscroll -p ' | ' --delay 0.2 \
	--length 30 \
	--match-command "$HOME/.config/waybar/scripts/escape-pango.sh 'mpc status'" \
	--match-text "playing" "--before-text ' '" \
	--match-text "paused" "--before-text ' ' --scroll 0" \
	--match-text "^volume:" "--before-text '' --scroll 0 --after-text ''" \
	--update-interval 1 \
	--update-check true "$HOME/.config/waybar/scripts/escape-pango.sh 'mpc current'" &
wait
