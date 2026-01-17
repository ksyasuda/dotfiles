#!/usr/bin/env bash

# Toggle desktop audio recording and attach the result to the newest Anki note
# (as tagged by Yomichan). Run once to start recording, run again to stop.
# Dependencies: jq, curl, ffmpeg/ffprobe, pulseaudio (parec+pactl), bc, notify-send

set -euo pipefail

ANKI_CONNECT_PORT="${ANKI_CONNECT_PORT:-8765}"
AUDIO_FIELD_NAME="${AUDIO_FIELD_NAME:-SentenceAudio}"
FORMAT="${FORMAT:-mp3}" # mp3 or ogg
CUT_DURATION="${CUT_DURATION:-0.1}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/record-audio"
RECORD_TIMEOUT="${RECORD_TIMEOUT:-60}"
ANKI_URL="http://localhost:${ANKI_CONNECT_PORT}"

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing dependency: $1" >&2
        exit 1
    }
}

notify() {
    # Best-effort notification; keep script running if notify-send is missing.
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -t 1000 "$@"
    fi
}

get_active_sink() {
    pactl list sinks short 2>/dev/null | awk '$6=="RUNNING"{print $1; exit 0}'
}

get_newest_note_id() {
    local response
    response=$(curl -sS "$ANKI_URL" -X POST -H 'Content-Type: application/json' \
        -d '{"action":"findNotes","version":6,"params":{"query":"is:new"}}')
    jq -r '.result[-1] // empty' <<<"$response"
}

update_anki_note() {
    local note_id="$1" audio_path="$2" filename="$3"

    local payload
    payload=$(jq -n --argjson noteId "$note_id" --arg field "$AUDIO_FIELD_NAME" \
        --arg path "$audio_path" --arg filename "$filename" '
        {action:"updateNoteFields",version:6,
         params:{note:{id:$noteId,fields:{($field):""},
                       audio:[{path:$path,filename:$filename,fields:[$field]}]}}}')

    curl -sS "$ANKI_URL" -X POST -H 'Content-Type: application/json' -d "$payload" >/dev/null
}

open_note_in_browser() {
    local note_id="$1"
    local payload
    payload=$(jq -n --argjson noteId "$note_id" '
        {action:"guiBrowse",version:6,params:{query:("nid:" + ($noteId|tostring))}}')
    curl -sS "$ANKI_URL" -X POST -H 'Content-Type: application/json' -d "$payload" >/dev/null
}

record_audio() {
    local note_id="$1"
    local sink
    sink=$(get_active_sink) || true

    if [[ -z "$sink" ]]; then
        notify "Record Error" "No running PulseAudio sink found"
        exit 1
    fi

    mkdir -p "$CACHE_DIR"

    local timestamp wav_file out_file
    timestamp=$(date +%s)
    wav_file="$CACHE_DIR/$timestamp.wav"
    out_file="$CACHE_DIR/$timestamp.$FORMAT"

    notify "Audio recording started"

    if ! timeout "$RECORD_TIMEOUT" parec -d"$sink" --file-format=wav "$wav_file"; then
        notify "Record Error" "No audio captured (timeout or sink issue)"
        rm -f "$wav_file"
        exit 1
    fi

    local input_duration output_duration
    input_duration=$(ffprobe -v error -select_streams a:0 \
        -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$wav_file")
    output_duration=$(echo "$input_duration - $CUT_DURATION" | bc -l)

    # Guard against negative durations
    if [[ $(echo "$output_duration < 0" | bc -l) -eq 1 ]]; then
        output_duration="0"
    fi

    case "$FORMAT" in
    ogg)
        ffmpeg -nostdin -y -i "$wav_file" -vn -codec:a libvorbis -b:a 64k \
            -t "$output_duration" "$out_file"
        ;;
    mp3)
        ffmpeg -nostdin -y -i "$wav_file" -vn -codec:a libmp3lame -qscale:a 1 \
            -t "$output_duration" "$out_file"
        ;;
    *)
        notify "Record Error" "Unknown format: $FORMAT"
        rm -f "$wav_file"
        exit 1
        ;;
    esac

    rm -f "$wav_file"

    update_anki_note "$note_id" "$out_file" "$timestamp.$FORMAT"
    open_note_in_browser "$note_id"

    notify "Audio recording copied"
    rm -f "$out_file"
}

main() {
    for cmd in curl jq ffmpeg ffprobe parec pactl bc; do
        require_cmd "$cmd"
    done

    if pgrep -x parec >/dev/null 2>&1; then
        pkill -x parec
        notify "Audio recording stopped"
        exit 0
    fi

    local newest_note
    newest_note=$(get_newest_note_id)

    if [[ -z "$newest_note" ]]; then
        notify "Anki Connect" "No new notes found or AnkiConnect unavailable"
        exit 1
    fi

    record_audio "$newest_note"
}

main "$@"
