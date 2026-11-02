if pgrep -x hypridle > /dev/null; then
    killall -9 hypridle
    notify-send "Presentation mode" "Off" -u low
else
    hypridle &
    notify-send "Presentation mode" "On" -u low
fi