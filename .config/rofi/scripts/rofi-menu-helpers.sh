#!/usr/bin/env bash

# Lightweight helpers to build rofi menus with label/value pairs.
# Intended to be sourced from other scripts.

# Allow callers to override theme/args without touching code.
: "${ROFI_THEME:=$HOME/.config/rofi/launchers/type-2/style-2.rasi}"
: "${ROFI_THEME_STR:="window {width: 25%;} listview {columns: 1; lines: 10;}"}"
: "${ROFI_DMENU_ARGS:=-i -l 5}"

# rofi_menu prompt option...
# Prints the selected option to stdout and propagates the rofi exit code
# (1 when the user cancels).
rofi_menu() {
	local prompt="$1"
	shift
	local -a options=("$@")

	local selection
	selection="$(printf "%s\n" "${options[@]}" | rofi -dmenu $ROFI_DMENU_ARGS \
		${ROFI_THEME:+-theme "$ROFI_THEME"} \
		${ROFI_THEME_STR:+-theme-str "$ROFI_THEME_STR"} \
		-p "$prompt")"
	local status=$?
	[[ $status -ne 0 ]] && return "$status"
	printf "%s\n" "$selection"
}

# rofi_select_label_value prompt array_name [back_label]
# array_name should contain entries shaped as "Label|Value".
# Prints the mapped value (or the back label when chosen). Returns 1 on cancel.
rofi_select_label_value() {
	local prompt="$1"
	local array_name="$2"
	local back_label="${3:-}"

	# Access caller's array by name
	local -n kv_source="$array_name"
	local -A kv_map=()
	local -a display=()

	for entry in "${kv_source[@]}"; do
		local label="${entry%%|*}"
		local value="${entry#*|}"
		kv_map["$label"]="$value"
		display+=("$label")
	done

	if [[ -n "$back_label" ]]; then
		kv_map["$back_label"]="$back_label"
		display+=("$back_label")
	fi

	local selection
	selection="$(rofi_menu "$prompt" "${display[@]}")" || return "$?"
	[[ -z "$selection" ]] && return 1
	printf "%s\n" "${kv_map[$selection]}"
}

# rofi_select_list prompt array_name
# Convenience wrapper for plain lists (no label/value mapping).
rofi_select_list() {
	local prompt="$1"
	local array_name="$2"
	local -n list_source="$array_name"
	rofi_menu "$prompt" "${list_source[@]}"
}

