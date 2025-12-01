#!/usr/bin/env bash

BROWSER=/usr/bin/zen-browser
OPTIONS=(
    "Arch Linux (btw)"
    "Hyprland"
)
ARCH=(
    "Archlinux Wiki|https://wiki.archlinux.org/title/Main_page"
)
HYPRLAND=(
    "Hyprland Docs|https://wiki.hypr.land/"
    "Hyprland Window Rules|https://wiki.hypr.land/Configuring/Window-Rules/"
)

get_url() {
    urls=("$@")
    display_urls=()
    declare -A url_map
    for url in "${urls[@]}"; do
        display_urls+=("${url%%|*}")
        label="${url%%|*}"
        url_map["$label"]="${url##*|}"
    done
    display_urls+=("Back")
    url_map["Back"]="Back"

    selection="$(printf "%s\n" "${display_urls[@]}" | rofi -theme-str 'window {width: 25%;} listview {columns: 1; lines: 10;}' -theme ~/.config/rofi/launchers/type-2/style-2.rasi -dmenu -l 5 -i -p "Select Documentation")"
    url="${url_map[$selection]}"

    if [ -z "$url" ]; then
        exit 0
    fi

    printf "%s\n" "$url"
}

get_docs_list() {
    selection="$(printf "%s\n" "${OPTIONS[@]}" | rofi -theme-str 'window {width: 25%;} listview {columns: 1; lines: 10;}' -theme ~/.config/rofi/launchers/type-2/style-2.rasi -dmenu -l 5 -i -p "Select Documentation Group")"
    case "$selection" in
    "Arch Linux (btw)")
        urls=("${ARCH[@]}")
        ;;
    "Hyprland")
        urls=("${HYPRLAND[@]}")
        ;;
    *)
        exit 0
        ;;
    esac

    printf "%s\n" "${urls[@]}"
}

main() {
    urls=("$(get_docs_list)")
    url="$(get_url "${urls[@]}")"
    if [ -z "$url" ]; then
        printf "No URL selected.\n"
        exit 0
    elif [ "$url" == "Back" ]; then
        main
        exit 0
    fi
    $BROWSER "$url" &>/dev/null &
}

main
