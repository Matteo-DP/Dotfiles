#!/bin/bash

SCREENNAME="HEADLESS-VNC"
IP="0.0.0.0"

echo "Warning: VNC not encrypted - only use on trusted networks"

cleanup-screen() {
    hyprctl output remove $SCREENNAME
}

echo "Starting VNC server on $IP for virtual display $SCREENNAME"

SCREENNAME="HEADLESS-VNC"
hyprctl output create headless "$SCREENNAME" && trap cleanup-screen EXIT
waypaper --restore &>/dev/null

IP_WLAN0=$(ip a s wlan0 | grep -oE 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $2}' 2>/dev/null)
if [[ ! -z $IP_WLAN0 ]]; then
    echo "[INFO] ip address for device 'wlan0': $IP_WLAN0"
fi

#wayvnc -o "$SCREENNAME" "$IP" 5900
wayvnc -o "$SCREENNAME" -C ~/.config/wayvnc/config
