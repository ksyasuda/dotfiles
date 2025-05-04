#!/bin/bash

CMD="$1"
BEFORE_SPACE="${CMD%% *}"
if command -v "$BEFORE_SPACE" &> /dev/null; then
	eval "$CMD" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/'\''/\&#39;/g'
else
	echo "$CMD" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/'\''/\&#39;/g'
fi
