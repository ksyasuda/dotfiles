#!/bin/sh

PLAYER="$1"

if [ -z "$PLAYER" ]; then
	echo "Usage: $0 <player>"
	exit 1
fi

STATUS="$(playerctl -p "$PLAYER" status)"

if [ -z "$STATUS" ] || [ "$STATUS" = "Stopped" ]; then
	exit 0
elif [ "$STATUS" = "Paused" ]; then
	STATUS=" "
elif [ "$STATUS" = "Playing" ]; then
	STATUS=" "
else
	exit 0
fi

TITLE="$(playerctl -p "$PLAYER" metadata title)"
ARTIST="$(playerctl -p "$PLAYER" metadata artist)"

printf "%s\n" "$STATUS$TITLE - $ARTIST"
