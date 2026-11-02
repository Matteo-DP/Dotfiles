#!/bin/bash

SHADER=$(hyprshade current)

if [ -z "$SHADER" ]; then
    notify-send "Dark mode" "on" -u low
elif [[ "$SHADER" == "dark" ]]; then
    notify-send "Dark mode" "off" -u low
fi

hyprshade toggle dark

