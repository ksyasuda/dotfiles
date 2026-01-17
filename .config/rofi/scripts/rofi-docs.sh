#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/rofi-menu-helpers.sh"

BROWSER=/usr/bin/zen-browser
DOC_GROUPS=(
    "Arch Linux (btw)|ARCH"
    "Hyprland|HYPRLAND"
)
ARCH=(
    "Archlinux Wiki|https://wiki.archlinux.org/title/Main_page"
)
HYPRLAND=(
    "Hyprland Docs|https://wiki.hypr.land/"
    "Hyprland Window Rules|https://wiki.hypr.land/Configuring/Window-Rules/"
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
        *)
            exit 0
            ;;
        esac

        selection="$(select_url "$urls_ref")" || exit 0
        if [[ "$selection" == "Back" ]]; then
            continue
        fi
        $BROWSER "$selection" &>/dev/null &
        exit 0
    done
}

main
