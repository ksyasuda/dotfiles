#!/usr/bin/env bash

# Wallhaven API configuration
WALLHAVEN_API="https://wallhaven.cc/api/v1"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
TOPICS=(
    "konosuba"
    "bunny girl senpai"
    "oshi no ko"
    "kill la kill"
    "lofi"
    "eminence in shadow"
    "132262 - Mobuseka"
)

# Create wallpaper directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Function to download a random wallpaper from Wallhaven
download_random_wallpaper() {
    # Select random topic
    local random_topic="${TOPICS[$RANDOM % ${#TOPICS[@]}]}"
    local query
    local display_name
    
    # Check if the topic is a tag ID with name
    if [[ "$random_topic" =~ ^([0-9]+)[[:space:]]*-[[:space:]]*(.+)$ ]]; then
        query="id:${BASH_REMATCH[1]}"
        display_name="${BASH_REMATCH[2]}"
    else
        query=$(echo "$random_topic" | sed 's/ /+/g')
        display_name="$random_topic"
    fi
    
    echo "Searching for wallpapers related to: $display_name" >&2
    
    # Get wallpapers from Wallhaven API
    local response=$(curl -s "$WALLHAVEN_API/search?q=$query&purity=100&categories=110&sorting=random")
    
    # Get all image URLs and select a random one
    local urls=($(echo "$response" | jq -r '.data[].path'))
    if [ ${#urls[@]} -eq 0 ]; then
        echo "No wallpapers found for topic: $display_name" >&2
        return 1
    fi
    
    local random_index=$((RANDOM % ${#urls[@]}))
    local url="${urls[$random_index]}"
    
    if [ -n "$url" ] && [ "$url" != "null" ]; then
        local filename=$(basename "$url")
        echo "Downloading: $filename" >&2
        curl -s "$url" -o "$WALLPAPER_DIR/$filename"
        if [ $? -eq 0 ]; then
            echo "$WALLPAPER_DIR/$filename"
            echo "$display_name" > "$WALLPAPER_DIR/.last_topic"
            return 0
        fi
    fi
    
    echo "No wallpapers found for topic: $display_name" >&2
    return 1
}

# Handle direct image file input
if [[ -f "$1" ]]; then
    echo "Changing wallpaper to $1"
    echo "$1" > "$HOME/.wallpaper"
    hyprctl hyprpaper reload ,"$1"
    notify-send -i hyprpaper -u normal "change-wallpaper.sh" "Wallpaper changed to ${1##*/}"
    exit 0
fi

# Download a new random wallpaper
new_wallpaper=$(download_random_wallpaper)

if [ -n "$new_wallpaper" ] && [ -f "$new_wallpaper" ]; then
    echo "Changing wallpaper to $new_wallpaper"
    echo "$new_wallpaper" > "$HOME/.wallpaper"
    
    # Get the topic used for this wallpaper
    topic=$(cat "$WALLPAPER_DIR/.last_topic")
    
    # Apply the selected wallpaper
    hyprctl hyprpaper reload ,"$new_wallpaper"
    notify-send -i hyprpaper -u normal "change-wallpaper.sh" "Wallpaper changed to ${new_wallpaper##*/wallpapers/} ($topic)"
else
    notify-send -i hyprpaper -u critical "change-wallpaper.sh" "Failed to download new wallpaper"
    exit 1
fi
