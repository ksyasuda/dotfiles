#!/bin/sh

# Version 1.2
# shoutout to https://gist.github.com/Cephian/f849e326e3522be9a4386b60b85f2f23 for the original script,
# https://github.com/xythh/ added the ankiConnect functionality
# toggle record computer audio (run once to start, run again to stop)
# dependencies: ffmpeg, pulseaudio, curl

# where recording gets saved, gets deleted after being imported to anki
DIRECTORY="$HOME/.cache/"
FORMAT="mp3" # ogg or mp3
# cut file since it glitches a bit at the end sometimes
CUT_DURATION="0.1"
#port used by ankiconnect
ankiConnectPort="8765"
# gets the newest created card, so make sure to create the card first with yomichan
newestNoteId=$(curl -s localhost:$ankiConnectPort -X POST -d '{"action": "findNotes", "version": 6, "params": { "query": "is:new"}}' | jq '.result[-1]')
#Audio field name
audioFieldName="SentenceAudio"

#if there is no newest note, you either have a complete empty anki or ankiconnect isn't running
if [ "$newestNoteId" = "" ]; then
	notify-send "anki connect not found"
	exit 1
fi

if pgrep -f "parec"; then
	pkill -f "parec"
else
	time=$(date +%s)
	name="$DIRECTORY/$time"
	wav_file="$name.wav"
	out_file="$name.$FORMAT"

	if ! [ -d "$DIRECTORY" ]; then
		mkdir "$DIRECTORY"
	fi
	notify-send -t 1000 "Audio recording started"
	#timeout 1m arecord -t wav -f cd "$wav_file"

	# just grabs last running source... may not always work if your pulseaudio setup is complicated
	if ! timeout 1m parec -d"$(pactl list sinks | grep -B1 'State: RUNNING' | sed -nE 's/Sink #(.*)/\1/p' | tail -n 1)" --file-format=wav "$wav_file"; then

		notify-send "Error recording " "most likely no audio playing"
		rm "$wav_file"
		exit 1
	fi

	input_duration=$(ffprobe -v error -select_streams a:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$wav_file")
	output_duration=$(echo "$input_duration"-"$CUT_DURATION" | bc)

	# encode file and delete OG
	if [ $FORMAT = "ogg" ]; then
		ffmpeg -i "$wav_file" -vn -codec:a libvorbis -b:a 64k -t "$output_duration" "$out_file"
	elif [ $FORMAT = "mp3" ]; then
		ffmpeg -i "$wav_file" -vn -codec:a libmp3lame -qscale:a 1 -t "$output_duration" "$out_file"
	else
		notify-send "Record Error" "Unknown format $FORMAT"
	fi
	rm "$wav_file"

	# Update newest note with recorded audio
	curl -s localhost:$ankiConnectPort -X POST -d '{

        "action": "updateNoteFields",
        "version": 6,
        "params": {
            "note": {
                "id": '"$newestNoteId"',
                "fields": {
                    "'$audioFieldName'": ""
                },
            "audio": [{
                "path": "'"$out_file"'",
                "filename": "'"$time"'.'$FORMAT'",
                "fields": [
                "'$audioFieldName'"
                ]
            }]
    }
}
}'
	# opens changed note, comment if you don't want it.
	curl -s localhost:$ankiConnectPort -X POST -d '{
    "action": "guiBrowse",
    "version": 6,
    "params": {
        "query": "nid:'"$newestNoteId"'"
    }
}'
	notify-send -t 1000 "Audio recording copied"
	rm "$out_file"
fi
