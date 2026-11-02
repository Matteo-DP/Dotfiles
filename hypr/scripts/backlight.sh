#!/usr/bin/env bash

# from https://github.com/JaKooLit/Hyprland-v3/blob/main/config/hypr/scripts/Brightness.sh

inc_backlight() {
    brightnessctl -q s +3%
    get_backlight && notify
}

dec_backlight() {
    brightnessctl -q s 3%-
    get_backlight && notify
}

get_backlight() {
    current=$(brightnessctl -m | cut -d, -f4 | sed 's/%//')
}

notify() {
    # Bottom-center OSD (~/.config/ags); fall back to a notification if it isn't running
    timeout 1 ags request -i osd backlight >/dev/null 2>&1 && return
    notify-send -e -h boolean:SWAYNC_BYPASS_DND:true -h string:x-canonical-private-synchronous:sys-notify -u low -h "int:value:$current" "Backlight"
}

# Execute accordingly
if [[ "$1" == "--inc" ]]; then
	inc_backlight
elif [[ "$1" == "--dec" ]]; then
	dec_backlight
else
	echo "No arguments"
fi
