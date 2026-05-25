#!/usr/bin/env bash

active="$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{ print $NF }')"

if [ -z "$active" ] || [ "$active" = "0x0" ]; then
    exit 0
fi

title="$(
    xprop -id "$active" _NET_WM_NAME WM_NAME 2>/dev/null \
        | awk -F' = ' '/_NET_WM_NAME|WM_NAME/ {
            gsub(/^"/, "", $2)
            gsub(/"$/, "", $2)
            print $2
            exit
        }'
)"

case "$title" in
    *" — Mozilla Firefox")
        title="🌎 ${title% — Mozilla Firefox}"
        ;;
    *" - Visual Studio Code")
        title="󰨞 ${title% - Visual Studio Code}"
        ;;
esac

printf '%s\n' "$title" | awk '{
    if (length($0) > 40) {
        print substr($0, 1, 40) "..."
    } else {
        print
    }
}'
