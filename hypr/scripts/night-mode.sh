temp=4000

if pgrep -x "hyprsunset" > /dev/null; then
	killall -9 hyprsunset
	notify-send "Night mode" "Off" -u low
else
	hyprsunset -t "$temp" &
	notify-send "Night mode" "On" -u low
fi
