#!/usr/bin/env bash

# from https://github.com/JaKooLit/Hyprland-v3/blob/main/config/hypr/scripts/Brightness.sh

inc_backlight() {
    brightnessctl -q s +10%
    get_backlight && notify
}

dec_backlight() {
    brightnessctl -q s 10%-
    get_backlight && notify
}

get_backlight() {
    current=$(brightnessctl -m | cut -d, -f4 | sed 's/%//')
}

notify() {
    notify-send -h string:x-canonical-private-synchronous:sys-notify -i brightnesssettings -u low -h "int:value:$current" "Backlight"
}

# Execute accordingly
if [[ "$1" == "--inc" ]]; then
	inc_backlight
elif [[ "$1" == "--dec" ]]; then
	dec_backlight
else
	echo "No arguments"
fi