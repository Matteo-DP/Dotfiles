if pgrep -x hypridle > /dev/null; then
    killall -9 hypridle
    notify-send -e -h boolean:SWAYNC_BYPASS_DND:true "Presentation mode" "Off" -u low
else
    hypridle &
    notify-send -e -h boolean:SWAYNC_BYPASS_DND:true "Presentation mode" "On" -u low
fi