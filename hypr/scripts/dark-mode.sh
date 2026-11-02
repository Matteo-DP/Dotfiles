#!/bin/bash

SHADER=$(hyprshade current)

if [ -z "$SHADER" ]; then
    notify-send -e -h boolean:SWAYNC_BYPASS_DND:true "Dark mode" "on" -u low
elif [[ "$SHADER" == "dark" ]]; then
    notify-send -e -h boolean:SWAYNC_BYPASS_DND:true "Dark mode" "off" -u low
fi

hyprshade toggle dark

