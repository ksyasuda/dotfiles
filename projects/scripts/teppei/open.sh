#!/usr/bin/env bash

EP="$1"
DIR="/truenas/sudacode/japanese/nihongo-con-teppei/Nihongo-Con-Teppei-E$EP.mp3"
export FONTCONFIG_FILE="$HOME/.config/mpv/mpv-fonts.conf"
if mpv --profile=builtin-pseudo-gui --vid=1 --external-file=pod/cover.jpg "$DIR"; then
	echo "Finished playing Nihongo Con Teppei E$EP"
else
	echo "Failed to play Nihongo Con Teppei E$EP"
fi
