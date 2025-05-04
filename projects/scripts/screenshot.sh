#!/usr/bin/env bash

# GUI Screenshot Tool for Wayland Using Zenity, Grim, Slurp, and Rofi

SCRIPT_NAME=$(basename "$0")
TMP_DIR=/tmp
DEFAULT_FILENAME=screenshot.png
TMP_SCREENSHOT="$TMP_DIR/$DEFAULT_FILENAME"
HYPRLAND_REGEX='.at[0],(.at[1]) .size[0]x(.size[1])'
REQUIREMENTS=(grim slurp rofi zenity wl-copy)
USE_NOTIFICATIONS=1
CHOICES=(
	"1. Select a region and save - slurp | grim -g - \"$TMP_SCREENSHOT\""
	"2. Select a region and copy to clipboard - slurp | grim -g - - | wl-copy"
	"3. Whole screen - grim \"$TMP_SCREENSHOT\""
	"4. Current window - hyprctl -j activewindow | jq -r \"${HYPRLAND_REGEX}\" | grim -g - \"$TMP_SCREENSHOT\""
	"5. Edit - slurp | grim -g - - | swappy -f -"
	"6. Quit - exit 0"
)

notify() {
	local body="$1"
	local title="$2"
	if [[ -z "$body" ]]; then
		echo "notify: No message provided"
		return 1
	fi
	if [[ -z "$title" ]]; then
		title="$SCRIPT_NAME"
	fi

	if ((USE_NOTIFICATIONS)); then
		notify-send "$title" "$body"
	else
		printf "%s\n%s\n" "$title" "$body"
	fi
	return 0
}

check_deps() {
	for cmd in "${REQUIREMENTS[@]}"; do
		if ! command -v "$cmd" &> /dev/null; then
			echo "Error: $cmd is not installed. Please install it first."
			exit 1
		fi
	done
}

main() {
	CHOICE="$(rofi -dmenu -i -p "Enter option or select from the list" \
		-mesg "Select a Screenshot Option" \
		-a 0 -no-custom -location 0 \
		-yoffset 30 -xoffset 30 \
		-theme-str 'listview {columns: 2; lines: 3;} window {width: 45%;}' \
		-window-title "$SCRIPT_NAME" \
		-format 'i' \
		<<< "$(printf "%s\n" "${CHOICES[@]%% - *}")")"

	if [[ -z "$CHOICE" ]]; then
		notify "No option selected." ""
		exit 0
	fi

	sleep 0.2 # give time for the rofi window to close
	CMD="${CHOICES[$CHOICE]#* -}"
	if [[ -z "$CMD" ]]; then
		notify "No option selected." ""
		exit 0
	fi

	# For option 2 (copy to clipboard), handle differently
	if [[ "$CHOICE" == "1" ]]; then
		if eval "$CMD"; then
			notify "Screenshot copied to clipboard"
			exit 0
		else
			notify "An error occurred while taking the screenshot."
			exit 1
		fi
	fi

	if ! eval "$CMD"; then
		notify "An error occurred while taking the screenshot."
		exit 1
	fi

	notify "screenshot.sh" "Screenshot saved temporarily.\nChoose where to save it permanently"

	FILE=$(zenity --file-selection --title="Save Screenshot" --filename="$DEFAULT_FILENAME" --save 2> /dev/null)
	case "$?" in
		0)
			if mv "$TMP_SCREENSHOT" "$FILE"; then
				notify "Screenshot saved to $FILE"
			else
				notify "Failed to save screenshot to $FILE"
			fi
			;;
		1)
			rm -f "$TMP_SCREENSHOT"
			notify "Screenshot discarded"
			;;
		-1)
			notify "An unexpected error has occurred."
			;;
	esac
}

check_deps
main
