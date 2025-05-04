#!/usr/bin/env bash

notify-send -a "rofi-wifi-menu" "Getting list of saved Wi-Fi networks..."

# Get the list of saved Wi-Fi connections (connection names)
saved_connections=$(nmcli connection show | awk '$3 == "wifi" {print $1}')

# Get the currently connected SSID
current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

# Build the wifi list, marking the active one
wifi_list=""
while IFS= read -r conn_name; do
    # Skip empty names
    if [[ -z "$conn_name" ]]; then
        continue
    fi
    # Get SSID for this connection
    ssid=$(nmcli -g 802-11-wireless.ssid connection show "$conn_name" 2>/dev/null)
    # Mark active connection if SSID matches
    if [[ "$ssid" == "$current_ssid" ]]; then
        active_icon=""
    else
        active_icon=""
    fi
    wifi_list+="$active_icon $conn_name"$'\n'
done <<< "$saved_connections"

connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
	toggle="󰖪  Disable Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
	toggle="󰖩  Enable Wi-Fi"
fi

# Use rofi to select wifi network
chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -config "$HOME/.config/rofi/catppuccin-default.rasi" -selected-row 1 -p "Wi-Fi SSID: ")
# Get name of connection
read -r chosen_id <<< "${chosen_network:2}"

if [ "$chosen_network" = "" ]; then
	exit
elif [ "$chosen_network" = "󰖩  Enable Wi-Fi" ]; then
	nmcli radio wifi on
elif [ "$chosen_network" = "󰖪  Disable Wi-Fi" ]; then
	nmcli radio wifi off
else
	# Message to show when connection is activated successfully
	success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
# Always use the connection name to connect
nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
fi
