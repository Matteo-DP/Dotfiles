#!/bin/bash

config="$HOME/.config/rofi/config-keyboard-switcher.rasi"

# Choose layout
layout=$(echo -e "AZERTY (BE)\nQWERTY (US)" | rofi -dmenu -p "Keyboard switcher" -config $config)
device="at-translated-set-2-keyboard" # todo: dont't hardcode this

log_info() {
    msg="Keyboard set to $layout"
    echo $msg
    notify-send "Keyboard switcher" "$msg"
}

log_error() {
    msg="Failed to set keyboard"
    echo $msg
    notify-send -u critical "Keyboard switcher" "$msg"
}

# Map layout to xkb values
case "$layout" in
  "AZERTY (BE)")
    if ! hyprctl switchxkblayout "$device" 0; then
        log_error
    fi
    ;;
  "QWERTY (US)")
    if ! hyprctl switchxkblayout "$device" 1; then
        log_error
    fi
    ;;
  *)
    exit 1
    ;;
esac

log_info $layout

# Reload Hyprland config
hyprctl reload

