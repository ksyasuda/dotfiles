#!/usr/bin/env bash

# Capture a region with slurp+grim. If AnkiConnect is available, attach the
# JPEG to the newest note; otherwise copy a PNG to the clipboard.

set -euo pipefail

ANKI_CONNECT_PORT="${ANKI_CONNECT_PORT:-8765}"
PICTURE_FIELD="${PICTURE_FIELD:-Picture}"
QUALITY="${QUALITY:-90}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/screenshot-anki"
ANKI_URL="http://localhost:${ANKI_CONNECT_PORT}"
HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"
REQUIREMENTS=(slurp grim wl-copy xdotool curl jq rofi)
ROFI_THEME_STR='listview {columns: 2; lines: 3;} window {width: 45%;}'
ROFI_THEME="$HOME/.config/rofi/launchers/type-2/style-2.rasi"
CAPTURE_MODE=""
DECK_NAME=""
AUTO_MODE=false

parse_opts() {
    while getopts "cd:" opt; do
        case "$opt" in
        c)
            CAPTURE_MODE="window"
            AUTO_MODE=true
            ;;
        d)
            DECK_NAME="$OPTARG"
            ;;
        *)
            echo "Usage: $0 [-c] [-n DECK_NAME]" >&2
            echo "  -c: Capture current window" >&2
            echo "  -n: Specify note name (e.g., Kiku)" >&2
            exit 1
            ;;
        esac
    done
}

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

drain_enter_key() {
    # Release lingering Enter press from launching via rofi so it
    # doesn't reach the next focused window (e.g., a game).
    xdotool keyup Return 2>/dev/null || true
    xdotool keyup KP_Enter 2>/dev/null || true
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

capture_current_window() {
    local fmt="$1" quality="$2" output="$3" geometry

    if [[ "$fmt" == "jpeg" ]]; then
        grim -w "$(hyprctl activewindow -j | jq -r '.address')" -t jpeg -q "$quality" "$output"
    else
        grim -w "$(hyprctl activewindow -j | jq -r '.address')" -t png "$output"
    fi
}

choose_capture_mode() {
    local selection
    selection=$(printf "%s\n%s\n" "Region (slurp)" "Current window (Hyprland)" |
        rofi -dmenu -i \
            -p "Capture mode" \
            -mesg "Select capture target" \
            -no-custom \
            -no-lazy-grab \
            -location 0 -yoffset 30 -xoffset 30 \
            -theme "$ROFI_THEME" \
            -theme-str "$ROFI_THEME_STR" \
            -window-title "screenshot-anki")

    if [[ -z "$selection" ]]; then
        notify "Screenshot cancelled" "No capture mode selected"
        exit 0
    fi

    if [[ "$selection" == "Current window (Hyprland)" ]]; then
        CAPTURE_MODE="window"
    else
        CAPTURE_MODE="region"
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
    local response query="is:new"
    if [[ -n "$DECK_NAME" ]]; then
        query="is:new deck:$DECK_NAME"
    fi
    response=$(curl -sS "$ANKI_URL" -X POST -H 'Content-Type: application/json' \
        -d "{\"action\":\"findNotes\",\"version\":6,\"params\":{\"query\":\"$query\"}}")
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
    parse_opts "$@"

    local requirements=("${REQUIREMENTS[@]}")
    for cmd in "${requirements[@]}"; do
        require_cmd "$cmd"
    done

    mkdir -p "$CACHE_DIR"
    local timestamp base newest_note image_path
    timestamp=$(date +%s)
    base="$CACHE_DIR/$timestamp"

    drain_enter_key

    # Only show interactive menu if not in auto mode
    if [[ "$AUTO_MODE" == false ]]; then
        choose_capture_mode
    fi

    if [[ "$CAPTURE_MODE" == "window" ]]; then
        require_cmd hyprctl
    fi

    wiggle_mouse
    newest_note=$(get_newest_note_id)

    local capture_fn="capture_region"
    if [[ "$CAPTURE_MODE" == "window" ]]; then
        capture_fn="capture_current_window"
    fi

    if [[ -n "$newest_note" ]]; then
        image_path="$base.jpg"
        "$capture_fn" "jpeg" "$QUALITY" "$image_path"
        update_note_with_image "$newest_note" "$image_path" "paste-$timestamp.jpg"
        open_note_in_browser "$newest_note"
        notify -i "$image_path" "Screenshot Taken" "Added to Anki note"
        rm -f "$image_path"
    else
        image_path="$base.png"
        "$capture_fn" "png" "" "$image_path"
        copy_to_clipboard "$image_path"
        notify -i "$image_path" "Screenshot Taken" "Copied to clipboard"
        rm -f "$image_path"
    fi
}

main "$@"
