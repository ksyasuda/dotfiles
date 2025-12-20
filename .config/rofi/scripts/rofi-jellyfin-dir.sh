#!/usr/bin/env bash

set -Eeuo pipefail

BASE_DIR="/truenas/jellyfin"

. "$HOME/.config/rofi/scripts/rofi-menu-helpers.sh"

ACTION="xdg-open"

# Theme for icon display
ICON_THEME="$HOME/.config/rofi/launchers/type-3/style-4.rasi"
ICON_THEME_STR='configuration {show-icons: true; icon-size: 128; dpi: 96;} window {width: 50%; height: 60%;} listview {columns: 3; lines: 5;}'

# Map display names to actual directory names
declare -A DIR_MAP=(
	["Anime"]="anime"
	["Movies"]="movies"
	["Manga"]="manga"
	["TV"]="tv"
	["YouTube"]="youtube"
	["Books"]="books"
	["Podcasts"]="podcasts"
	["Audiobooks"]="audiobooks"
)

DIRS=(
	"Anime"
	"Movies"
	"Manga"
	"TV"
	"YouTube"
	"Books"
	"Podcasts"
	"Audiobooks"
)

# Select top-level category
CHOICE=$(rofi_select_list "Select a category" DIRS) || exit 1

# Get the actual directory name
ACTUAL_DIR="${DIR_MAP[$CHOICE]}"
TARGET_DIR="$BASE_DIR/$ACTUAL_DIR"

if [[ ! -d "$TARGET_DIR" ]]; then
	notify-send -u critical "Jellyfin Browser" "Directory not found: $TARGET_DIR"
	exit 1
fi

# Build rofi entries with folder.jpg icons
build_icon_menu() {
	local dir="$1"
	local entries=""

	while IFS= read -r -d '' subdir; do
		local name
		name="$(basename "$subdir")"
		local icon="$subdir/folder.jpg"

		# Check for folder.jpg, fallback to folder.png, then no icon
		if [[ -f "$icon" ]]; then
			entries+="${name}\0icon\x1f${icon}\n"
		elif [[ -f "$subdir/folder.png" ]]; then
			entries+="${name}\0icon\x1f${subdir}/folder.png\n"
		else
			entries+="${name}\n"
		fi
	done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

	printf "%b" "$entries"
}

# Show subdirectories with icons
SELECTION=$(build_icon_menu "$TARGET_DIR" | rofi -dmenu -i -no-custom \
	-theme "$ICON_THEME" \
	-theme-str "$ICON_THEME_STR" \
	-p "Select from $CHOICE") || exit 1

# Full path to selected item
SELECTED_PATH="$TARGET_DIR/$SELECTION"

if [[ -d "$SELECTED_PATH" ]]; then
	# Open in file manager or do something with it
	# You can customize this action as needed
	$ACTION "$SELECTED_PATH" &>/dev/null &
else
	notify-send -u critical "Jellyfin Browser" "Path not found: $SELECTED_PATH"
	exit 1
fi
