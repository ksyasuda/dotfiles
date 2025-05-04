#!/usr/bin/env bash

arg="$1"

# if arg is add, add a new password
# if arg is edit, edit an existing password
# if arg is delete, delete an existing password

case "$arg" in
	add)
		name="$(rofi -dmenu -l 0 -config ~/.config/aniwrapper/themes/aniwrapper-dracula.rasi -theme-str 'window {width: 35%;}' -p 'SAVED NAME:')"
		username="$(rofi -dmenu -l 0 -config ~/.config/aniwrapper/themes/aniwrapper-dracula.rasi -theme-str 'window {width: 35%;}' -p 'USERNAME:')"
		printf "%s %s\n" "$name" "$username"
		if [[ -z "$name" || -z "$username" ]]; then
			printf "%s\n" "Name and username cannot be empty"
			exit 1
		fi
		rbw add "$name" "$username"
		;;
	edit)
		exit 1
		;;
	delete)
		exit 1
		;;
	*)
		printf "%s\n" "Not implemented"
		exit 1
		;;
esac
