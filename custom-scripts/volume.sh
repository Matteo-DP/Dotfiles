#!/bin/bash

# from https://github.com/JaKooLit/Hyprland-v3/blob/main/config/hypr/scripts/Volume.sh

state="low" # default, can be overwritten

get_volume() {
    # current=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed -E 's/Volume: 0\.([0-9]+)/\1/')
    current=$(pactl get-sink-volume @DEFAULT_SINK@ | sed -n 's/.* \([0-9]\+\)% .*/\1/p')
    if   [ "$current" -le "20" ]; then
		icon="audio-volume-low"
	elif [ "$current" -le "60" ]; then
		icon="audio-volume-medium"
	elif [ "$current" -le "100" ]; then
		icon="audio-volume-high"
	else
        title="Volume - overamplified!"
		icon="audio-volume-high"
        state="critical"
	fi
}

notify() {
    notify-send -h string:x-canonical-private-synchronous:sys-notify -i "$icon" -u $state -h "int:value:$current" "$title"
}

inc_volume() {
    title="Volume"
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    get_volume && notify
}

dec_volume() {
    title="Volume" # Can be overwritten in functions
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    get_volume && notify
}

toggle_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    if pactl get-sink-mute @DEFAULT_SINK@ | grep -q "Mute: yes"; then
        title="Volume muted"
        current=0
        icon="audio-volume-muted"
    else
        title="Volume unmuted"
        get_volume
    fi
    notify
}

toggle_mic() {
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
    icon="audio-input-microphone"
    if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "Mute: yes"; then
        title="Mic muted"
        current=0
    else
        title="Mic unmuted"
        get_mic
    fi
    notify
}

get_mic() {
    current=$(pactl get-source-volume @DEFAULT_SOURCE@ | sed -n 's/.* \([0-9]\+\)% .*/\1/p')
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
	get_volume
elif [[ "$1" == "--inc" ]]; then
	inc_volume
elif [[ "$1" == "--dec" ]]; then
	dec_volume
elif [[ "$1" == "--toggle-volume" ]]; then
	toggle_mute
elif [[ "$1" == "--toggle-mic" ]]; then
	toggle_mic
else
	get_volume
fi