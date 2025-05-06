#!/bin/bash

api="$HOME/.config/custom-scripts/power-profiles.sh"
stats="$HOME/.config/custom-scripts/battery-health.sh"
config="$HOME/.config/rofi/config-power-profiles.rasi"

profile=$(echo -e "Automatic (Performance/Balanced)\nPerformance\nBalanced\nBattery saver\nView stats" | rofi -dmenu -p "Power profiles" -config $config -mesg "Current profile: $($api 'get')")

if [[ -z $profile ]]; then
    echo "Cancelled"
    exit 0
fi

case "$profile" in
    "View stats")
        kitty --class "dotfiles-floating" -e "$stats"
        ;;
    "Automatic (Performance/Balanced)")
        bash $api set "automatic"
        ;;
    "Performance")
        bash $api set "performance"
        ;;
    "Balanced")
        bash $api set "balanced"
        ;;
    "Battery saver")
        bash $api set "battery-saver"
        ;;
    *)
        notify-send -u critical "Power switcher" "Error: $profile not recognised"
        exit 1
        ;;
esac

exit 0

