#!/bin/sh

music_dir="/jellyfin/music"
previewdir="$XDG_CONFIG_HOME/ncmpcpp/previews"
filename="$(mpc --format "$music_dir"/%file% current)"
previewname="$previewdir/$(mpc --format %album% current | base64).png"

[ -e "$previewname" ] || ffmpeg -y -i "$filename" -an -vf scale=128:128 "$previewname" > /dev/null 2>&1

notify-send -a "ncmpcpp" "Now Playing" "$(mpc --format '%title% \n%artist% - %album%' current)" -i "$previewname"
