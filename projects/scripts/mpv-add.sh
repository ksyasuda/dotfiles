#!/usr/bin/env bash

set -Eeuo pipefail

URL="${1:-}"
MPV_SOCKET="/tmp/mpvsocket"
ICON_PATH="$HOME/.local/share/icons/Magna-Glassy-Dark-Icons/apps/48/mpv.svg"
TITLE="mpv-add.sh"

notify() {
	local message="$1"
	notify-send -i "$ICON_PATH" "$TITLE" "$message"
}

trim() {
	printf '%s' "$1" | sed 's/^[[:space:]]\+//;s/[[:space:]]\+$//'
}

play_direct() {
	mpv -- "$URL" &> /dev/null &
}

wait_for_socket() {
	local timeout_ms=2000
	local waited=0
	while ((waited < timeout_ms)); do
		if [[ -S "$MPV_SOCKET" ]]; then
			return 0
		fi
		sleep 0.05
		waited=$((waited + 50))
	done
	return 1
}

is_valid_input() {
	local input="$1"

	if [[ -f "$input" ]]; then
		return 0
	fi

	if ! command -v yt-dlp > /dev/null 2>&1; then
		return 1
	fi

	if yt-dlp --simulate "$input" > /dev/null 2>&1; then
		return 0
	fi

	return 1
}

if [[ -z "$URL" ]] && command -v wl-paste > /dev/null 2>&1; then
	URL="$(wl-paste -p || true)"
fi

URL="$(trim "$URL")"

if [[ -z "$URL" ]]; then
	notify "No URL provided"
	exit 1
fi

if ! is_valid_input "$URL"; then
	notify "Invalid input: provide a local file path or a yt-dlp supported URL"
	exit 1
fi

if ! pgrep -x mpv &> /dev/null; then
	rm -f "$MPV_SOCKET"
	mpv --input-ipc-server="$MPV_SOCKET" -- "$URL" &> /dev/null &
	notify "Playing $URL"
else
	if [[ -S "$MPV_SOCKET" ]] && wait_for_socket && echo "{ \"command\": [\"script-message\", \"add_to_queue\", \"$URL\" ] }" | socat - "$MPV_SOCKET" &> /dev/null; then
		notify "Added $URL to queue"
		exit 0
	fi

	notify "Queue unavailable, opening in new player"
	play_direct
	notify "Playing $URL"
fi
