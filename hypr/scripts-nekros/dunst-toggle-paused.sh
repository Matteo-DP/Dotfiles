#!/bin/bash

# Check if dunst is currently paused
if dunstctl is-paused | grep -q true; then
    # It's paused, so unpause
    dunstctl set-paused false
    echo "Dunst unpaused"
else
    # It's not paused, so pause
    dunstctl set-paused true
    echo "Dunst paused"
fi
