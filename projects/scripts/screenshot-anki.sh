#!/bin/sh

# Version 1.2
# click and drag to screenshot dragged portion
# click on specific window to screenshot window area
# dependencies: imagemagick, xclip,curl maybe xdotool (see comment below)
# shoutout to https://gist.github.com/Cephian/f849e326e3522be9a4386b60b85f2f23 for the original script,
# https://github.com/xythh/ added the ankiConnect functionality
# if anki is running the image is added to your latest note as a jpg, if anki is not running it's added to your clipboard as a png
time=$(date +%s)
tmp_file="$HOME/.cache/$time"
ankiConnectPort="8765"
pictureField="Picture"
quality="90"

# This gets your notes marked as new and returns the newest one.
newestNoteId=$(curl -s localhost:$ankiConnectPort -X POST -d '{"action": "findNotes", "version": 6, "params": { "query": "is:new"}}' | jq '.result[-1]')

# you can remove these two lines if you don't have software which
# makes your mouse disappear when you use the keyboard (e.g. xbanish, unclutter)
# https://github.com/ImageMagick/ImageMagick/issues/1745#issuecomment-777747494
xdotool mousemove_relative 1 1
xdotool mousemove_relative -- -1 -1

# if anki connect is running it will return your latest note id, and the following code will run, if anki connect is not running nothing is return.
if [ "$newestNoteId" != "" ]; then
	if ! import -quality $quality "$tmp_file.jpg"; then
		# most likley reason this returns a error, is for fullscreen applications that take full control which does not allowing imagemagick to select the area, use windowed fullscreen or if running wine use a virtual desktop to avoid this.
		notify-send "Error screenshoting " "most likely unable to find selection"
		exit 1
	fi

	curl -s localhost:$ankiConnectPort -X POST -d '{
    "action": "updateNoteFields",
    "version": 6,
    "params": {
        "note": {
            "id": '"$newestNoteId"',
	    "fields": {
                "'$pictureField'": ""
            },
            "picture": [{
                "path": "'"$tmp_file"'.jpg",
                "filename": "paste-'"$time"'.jpg",
                "fields": [
                    "'$pictureField'"
                ]
            }]
        }
    }
}'

	#remove if you don't want anki to show you the card you just edited
	curl -s localhost:$ankiConnectPort -X POST -d '{
    "action": "guiBrowse",
    "version": 6,
    "params": {
        "query": "nid:'"$newestNoteId"'"
    }
}'

	#you can comment this if you do not use notifcations.
	notify-send "Screenshot Taken" "Added to note"
	rm "$tmp_file.jpg"
else
	if ! import -quality $quality "$tmp_file.png"; then
		notify-send "Error screenshoting " "most likely unable to find selection"
		exit 1
	fi
	# we use pngs when copying to clipboard because they have greater support when pasting.
	xclip -selection clipboard -target image/png -i "$tmp_file.png"
	rm "$tmp_file.png"
	#you can comment this if you do not use notifcations.
	notify-send "Screenshot Taken" "Copied to clipboard"
fi
