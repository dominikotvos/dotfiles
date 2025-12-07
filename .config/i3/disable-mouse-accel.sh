#!/bin/bash

until xinput list > /dev/null 2>&1; do
    sleep 1
done

sleep 2

# Find all slave pointer devices matching "Razer DeathAdder"
xinput list | \
    grep -i "razer.*deathadder" | \
    grep -i "slave.*pointer" | \
    grep -o "id=[0-9]*" | \
    cut -d= -f2 | \
    while read id; do
        if [ -n "$id" ]; then
            xinput set-prop "$id" "libinput Accel Profile Enabled" 0, 1, 0
        fi
    done
