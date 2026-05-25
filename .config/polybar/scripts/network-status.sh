#!/usr/bin/env bash

if ! command -v nmcli >/dev/null 2>&1; then
    echo "wifi disconnected"
    exit 0
fi

wifi_device="$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
    | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')"

if [ -n "$wifi_device" ]; then
    ssid="$(nmcli -t -f ACTIVE,SSID device wifi list ifname "$wifi_device" 2>/dev/null \
        | awk -F: '$1 == "yes" { print $2; exit }')"
    if [ -n "$ssid" ]; then
        echo "wifi: $ssid"
    else
        echo "wifi: $wifi_device"
    fi
    exit 0
fi

ethernet_device="$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
    | awk -F: '$2 == "ethernet" && $3 == "connected" { print $1; exit }')"

if [ -n "$ethernet_device" ]; then
    echo "$ethernet_device"
    exit 0
fi

echo "wifi disconnected"
