temp=4000

if pgrep -x "hyprsunset" > /dev/null; then
	killall -9 hyprsunset
	notify-send -e -h boolean:SWAYNC_BYPASS_DND:true "Night mode" "Off" -u low
else
	hyprsunset -t "$temp" &
	notify-send -e -h boolean:SWAYNC_BYPASS_DND:true "Night mode" "On" -u low
fi
