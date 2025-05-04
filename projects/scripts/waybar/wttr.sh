#!/usr/bin/env bash

for _ in {1..5}; do
	text="$(curl -s "https://wttr.in/$1?format=1" | sed -E "s/\s+/ /g")"
	if [[ "$?" = 0 ]]; then
		# text="$(echo "$text" | awk '{print $2}')"
		tooltip=$(curl -s "https://wttr.in/$1?format=4")
		if [ "$?" = 0 ]; then
			tooltip=$(echo "$tooltip" | sed -E "s/\s+/ /g")
			echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
			exit
		fi
	fi
	sleep 2
done
echo "{\"text\":\"error\", \"tooltip\":\"error\"}"
