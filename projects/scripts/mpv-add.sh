#!/usr/bin/env bash

set -Eeuo pipefail

URL="${1:-$(wl-paste -p)}"
MPV_SOCKET=/tmp/mpvsocket
ICON_PATH="$HOME/.local/share/icons/Magna-Glassy-Dark-Icons/apps/48/mpv.svg"
TITLE="mpv-add.sh"

if [[ -z "$URL" ]]; then
	notify-send -i "$ICON_PATH" "$TITLE" "No URL provided"
	exit 1
fi

if ! [[ -f "$URL" ]] && ! yt-dlp --simulate "$URL"; then
	notify-send -i "$ICON_PATH" "$TITLE" "Invalid URL"
	exit 1
fi

if ! pgrep -x mpv &> /dev/null; then
	mpv "$URL" &> /dev/null &
	notify-send -i "$ICON_PATH" "$TITLE" "Playing $URL"
else
	if echo "{ \"command\": [\"script-message\", \"add_to_queue\", \"$URL\" ] }" | socat - "$MPV_SOCKET" &> /dev/null; then
		notify-send -i "$ICON_PATH" "$TITLE" "Added $URL to queue"
	else
		notify-send -i "$ICON_PATH" "$TITLE" "Failed to add $URL to queue"
	fi
fi
