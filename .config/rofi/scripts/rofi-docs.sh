#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/rofi-menu-helpers.sh"

BROWSER=/usr/bin/helium-browser
DOC_GROUPS=(
	"Arch Linux (btw)|ARCH"
	"Hyprland|HYPRLAND"
	"EVO|EVO80"
)
ARCH=(
	"Archlinux Wiki|https://wiki.archlinux.org/title/Main_page"
)
HYPRLAND=(
	"Hyprland Docs|https://wiki.hypr.land/"
	"Hyprland Window Rules|https://wiki.hypr.land/Configuring/Window-Rules/"
)
EVO80=(
	"Reference|feh $HOME/Documents/screenshots/reference/evo80/EVO80-Wireless-Keyboard-Reference.webp"
	"Backlight|feh $HOME/Documents/screenshots/reference/evo80/EVO80-Wireless-Keyboard-Backlight-LED.webp"
	"Modes|feh $HOME/Documents/screenshots/reference/evo80/EVO80-Wireless-Keyboard-Modes.webp"
)

select_group() {
	rofi_select_label_value "Select Documentation Group" DOC_GROUPS
}

select_url() {
	local urls_array="$1"
	rofi_select_label_value "Select Documentation" "$urls_array" "Back"
}

main() {
	while true; do
		group_key="$(select_group)" || exit 0
		case "$group_key" in
			ARCH)
				urls_ref=ARCH
				;;
			HYPRLAND)
				urls_ref=HYPRLAND
				;;
			EVO80)
				urls_ref=EVO80
				;;
			*)
				exit 0
				;;
		esac

		selection="$(select_url "$urls_ref")" || exit 0
		if [[ "$selection" == "Back" ]]; then
			continue
		fi
		if [[ "$selection" == feh* ]]; then
			bash -c "$selection" &> /dev/null &
			exit $?
		fi
		$BROWSER "$selection" &> /dev/null &
		exit 0
	done
}

main
