#!/usr/bin/env bash

# Capture a region with slurp+grim. If AnkiConnect is available, attach the
# JPEG to the newest note; otherwise copy a PNG to the clipboard.

set -euo pipefail

ANKI_CONNECT_PORT="${ANKI_CONNECT_PORT:-8765}"
PICTURE_FIELD="${PICTURE_FIELD:-Picture}"
QUALITY="${QUALITY:-90}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/screenshot-anki"
ANKI_URL="http://localhost:${ANKI_CONNECT_PORT}"
REQUIREMENTS=(slurp grim wl-copy xdotool curl jq)

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$@"
    fi
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        notify "Missing dependency" "$1 is required"
        exit 1
    }
}

wiggle_mouse() {
    # Avoid disappearing cursor on some compositors
    xdotool mousemove_relative 1 1
    xdotool mousemove_relative -- -1 -1
}

capture_region() {
    local fmt="$1" quality="$2" output="$3"
    local geometry
    geometry=$(slurp)
    if [[ -z "$geometry" ]]; then
        notify "Screenshot cancelled" "No region selected"
        exit 1
    fi
    if [[ "$fmt" == "jpeg" ]]; then
        grim -g "$geometry" -t jpeg -q "$quality" "$output"
    else
        grim -g "$geometry" -t png "$output"
    fi
}

copy_to_clipboard() {
    local file="$1"
    if ! wl-copy <"$file"; then
        notify "Error copying screenshot" "wl-copy failed"
        exit 1
    fi
}

get_newest_note_id() {
    local response
    response=$(curl -sS "$ANKI_URL" -X POST -H 'Content-Type: application/json' \
        -d '{"action":"findNotes","version":6,"params":{"query":"is:new"}}')
    jq -r '.result[-1] // empty' <<<"$response"
}

update_note_with_image() {
    local note_id="$1" image_path="$2" filename="$3"
    local payload
    payload=$(jq -n --argjson noteId "$note_id" --arg field "$PICTURE_FIELD" \
        --arg path "$image_path" --arg filename "$filename" '
        {action:"updateNoteFields",version:6,
         params:{note:{id:$noteId,fields:{($field):""},
                       picture:[{path:$path,filename:$filename,fields:[$field]}]}}}')
    curl -sS "$ANKI_URL" -X POST -H 'Content-Type: application/json' -d "$payload" >/dev/null
}

open_note_in_browser() {
    local note_id="$1"
    local payload
    payload=$(jq -n --argjson noteId "$note_id" '
        {action:"guiBrowse",version:6,params:{query:("nid:" + ($noteId|tostring))}}')
    curl -sS "$ANKI_URL" -X POST -H 'Content-Type: application/json' -d "$payload" >/dev/null
}

main() {
    for cmd in "${REQUIREMENTS[@]}"; do
        require_cmd "$cmd"
    done

    mkdir -p "$CACHE_DIR"
    local timestamp base newest_note image_path
    timestamp=$(date +%s)
    base="$CACHE_DIR/$timestamp"

    wiggle_mouse
    newest_note=$(get_newest_note_id)

    if [[ -n "$newest_note" ]]; then
        image_path="$base.jpg"
        capture_region "jpeg" "$QUALITY" "$image_path"
        update_note_with_image "$newest_note" "$image_path" "paste-$timestamp.jpg"
        open_note_in_browser "$newest_note"
        notify -i "$image_path" "Screenshot Taken" "Added to Anki note"
        rm -f "$image_path"
    else
        image_path="$base.png"
        capture_region "png" "" "$image_path"
        copy_to_clipboard "$image_path"
        notify -i "$image_path" "Screenshot Taken" "Copied to clipboard"
        rm -f "$image_path"
    fi
}

main "$@"
