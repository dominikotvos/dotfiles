#!/bin/bash
current_layout=$(setxkbmap -query | awk '/variant/ {print $2}')

if [ "$current_layout" = "dvorak" ]; then
	setxkbmap us # Switch to QWERTY ('intl' variant)
else
	setxkbmap us -variant dvorak # Switch to Dvorak
fi
