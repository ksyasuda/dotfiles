#!/bin/sh

PLAYER="$1"

if [ -z "$PLAYER" ]; then
    echo "Usage: $0 <player>"
    exit 1
fi

STATUS="$(playerctl -sp "$PLAYER" status)"

case "$STATUS" in "" | "Stopped")
    exit 0
    ;;
"Paused")
    STATUS=" "
    ;;
"Playing")
    STATUS=" "
    ;;
esac

TITLE="$(playerctl -p "$PLAYER" metadata title)"
ARTIST="$(playerctl -p "$PLAYER" metadata artist)"

printf "%s\n" "$STATUS$TITLE - $ARTIST"
