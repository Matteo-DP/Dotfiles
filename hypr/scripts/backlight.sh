#!/usr/bin/env bash

# from https://github.com/JaKooLit/Hyprland-v3/blob/main/config/hypr/scripts/Brightness.sh

STEP=3        # normal step (%)
FINE_BELOW=5  # at or below this level, step by 1%

get_backlight() {
    current=$(brightnessctl -m | cut -d, -f4 | sed 's/%//')
}

set_backlight() {
    brightnessctl -q s "$1%"
    current=$1
}

inc_backlight() {
    get_backlight
    if (( current < FINE_BELOW )); then
        set_backlight $(( current + 1 ))
    else
        set_backlight $(( current + STEP > 100 ? 100 : current + STEP ))
    fi
    notify
}

dec_backlight() {
    get_backlight
    local new
    if (( current > FINE_BELOW )); then
        # Don't jump past the 1% steps
        new=$(( current - STEP < FINE_BELOW ? FINE_BELOW : current - STEP ))
    else
        new=$(( current - 1 ))
    fi
    # Only reach 0% when starting from exactly 1%
    (( new < 1 && current > 1 )) && new=1
    (( new < 0 )) && new=0
    set_backlight "$new"
    notify
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
