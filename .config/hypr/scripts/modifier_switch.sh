#!/bin/bash

# --- CONFIGURATION ---
LOST_ARK_CLASS="steam_app_1599340"
# A temporary file to store the current modifier state ("alt" or "super")
STATE_FILE="/tmp/hypr_mod_state"

# --- FUNCTION TO SWITCH CONFIGS ---
switch_configs() {
    # Get active window info
    local active_window_json
    active_window_json=$(hyprctl activewindow -j)
    if [ -z "$active_window_json" ]; then return; fi

    local active_class
    active_class=$(echo "$active_window_json" | jq -r '.class')
    local active_title
    active_title=$(echo "$active_window_json" | jq -r '.title')

    # Read the current state from our state file
    local current_state
    current_state=$(cat "$STATE_FILE")

    # --- LOGIC ---
    # Are we focused on Lost Ark?
    if [[ "$active_class" == *"$LOST_ARK_CLASS"* ]] || [[ "$active_title" == *"$LOST_ARK_CLASS"* ]]; then
        # Is the current state already "super"? If not, switch.
        if [[ "$current_state" != "super" ]]; then
            echo "Switching to SUPER modifier for Lost Ark..."
            hyprctl --batch "keyword unbind all; keyword source ~/.config/hypr/keys-super.conf"
            # Update the state file
            echo "super" > "$STATE_FILE"
        fi
    # If not Lost Ark, it's a general window
    else
        # Is the current state already "alt"? If not, switch back.
        if [[ "$current_state" != "alt" ]]; then
            echo "Switching back to ALT modifier for general use..."
            hyprctl --batch "keyword unbind all; keyword source ~/.config/hypr/keys-alt.conf"
            # Update the state file
            echo "alt" > "$STATE_FILE"
        fi
    fi
}

# --- INITIALIZATION ---
# Set the initial state to "alt" when the script starts
echo "alt" > "$STATE_FILE"
# Run once at start, just in case
switch_configs

# --- EVENT LISTENER ---
# Listen for window focus changes and run the function
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r event; do
    if [[ ${event:0:12} == "activewindow" ]]; then
        switch_configs
    fi
done
