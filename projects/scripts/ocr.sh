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

slurp | grim -g - /tmp/ocr.png || exit 1
transformers_ocr recognize --image-path /tmp/ocr.png || exit 1
notify-send "tramsformers_ocr" "Text: $DISPLAY_RES"
