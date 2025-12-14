#!/bin/bash
set -Eeuo pipefail

# RES="$(slurp | grim -g - - | gazou | sed '1d;$d')"
# # Truncate RES for display if it's longer than 100 characters
# DISPLAY_RES="${RES:0:100}"
# if [ ${#RES} -gt 100 ]; then
# 	DISPLAY_RES="${DISPLAY_RES}..."
# fi
# notify-send "GAZOU" "Text: $DISPLAY_RES"
# echo "$RES" | wl-copy

# grim -g "$(slurp)" /tmp/ocr.png || exit 1
# slurp | grim -g - /tmp/ocr/ocr.png || exit 1
owocr -r clipboard -w clipboard -of text -n || exit 1
slurp | grim -g - | wl-copy
notify-send "ocr.sh" "Text: $DISPLAY_RES"
