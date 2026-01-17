#!/bin/bash
set -Eeuo pipefail

if ! pgrep -af owocr; then
    notify-send "ocr.sh" "Starting owocr daemon..."
    owocr -e meikiocr -r clipboard -w clipboard -l ja -n &>/dev/null &
fi
slurp | grim -g - - | wl-copy
notify-send "ocr.sh" "Text: $DISPLAY_RES"
