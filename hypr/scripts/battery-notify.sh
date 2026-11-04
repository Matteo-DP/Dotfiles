#!/usr/bin/env bash
# Battery notifications for batsignal (see ~/.config/batsignal).
# batsignal calls: battery-notify.sh <warning|critical|danger|charging> [level]

KIND="$1"
BAT=/sys/class/power_supply/BAT0
ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/battery-notify.id"

level="${2:-$(cat "$BAT/capacity" 2>/dev/null)}"

# Estimated time until empty, e.g. "1 h 12 min" (empty if unknown)
time_left() {
    local now rate minutes
    if [[ -r $BAT/charge_now && -r $BAT/current_now ]]; then
        now=$(<"$BAT/charge_now") rate=$(<"$BAT/current_now")
    elif [[ -r $BAT/energy_now && -r $BAT/power_now ]]; then
        now=$(<"$BAT/energy_now") rate=$(<"$BAT/power_now")
    fi
    if [[ -n $rate && $rate -gt 0 ]]; then
        minutes=$(( now * 60 / rate ))
        if (( minutes >= 60 )); then
            echo "$(( minutes / 60 )) h $(( minutes % 60 )) min"
        else
            echo "$minutes min"
        fi
    fi
}

# Close the previous battery notification (e.g. after plugging in)
close_previous() {
    [[ -s $ID_FILE ]] || return
    gdbus call --session --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.CloseNotification "$(<"$ID_FILE")" >/dev/null 2>&1
    rm -f "$ID_FILE"
}

case "$KIND" in
    warning)
        title="Battery low"
        icon="battery-low"
        ;;
    critical)
        title="Battery critical"
        icon="battery-caution"
        ;;
    danger)
        title="Battery almost empty"
        icon="battery-empty"
        ;;
    charging)
        close_previous
        exit 0
        ;;
    *)
        exit 0 # empty / unknown messages (e.g. discharging) are ignored
        ;;
esac

remaining=$(time_left)
body="${level}% left"
[[ -n $remaining ]] && body+=" · about ${remaining} remaining"

args=(
    -u critical
    -a "Battery"
    -i "$icon"
    -h boolean:SWAYNC_BYPASS_DND:true
    -p
)
# Replace the previous battery notification instead of stacking them
[[ -s $ID_FILE ]] && args+=(-r "$(<"$ID_FILE")")

notify-send "${args[@]}" "$title" "$body" > "$ID_FILE"
