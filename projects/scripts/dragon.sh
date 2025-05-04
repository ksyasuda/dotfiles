#!/bin/bash
set -Eeuo pipefail
HOME="/home/$(whoami)"
clip="$(wl-paste)"
if [[ -z "$clip" ]]; then
	notify-send "Dragon" "Clipboard is empty"
	exit 1
fi
DIR="$(hyprctl activeworkspace | grep -i lastwindowtitle | sed 's/\slastwindowtitle: //')"
DIR="${DIR//\~/$HOME}"
PTH="$DIR/$(basename "$clip")"
if [[ -e "$PTH" ]]; then
	dragon-drop "$PTH"
fi
