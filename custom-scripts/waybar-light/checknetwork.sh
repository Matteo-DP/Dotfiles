#!/bin/bash

if [ -z "$HOME_SSID" ]; then
    # not sure how to notify the user that someting is up without being obnoxiuos in dunst, echo gets piped
    # echo "HOME_SSID environment variable not set."
    # echo "{\"class\": \"inactive\"}"
    exit 1
fi

# Get current SSID
SSID=$(nmcli -t -f name connection show --active)

# grep -iq: returns 0 when found, -i for case insenitive
if echo "$SSID" | grep -iq "$HOME_SSID"; then
    echo "{\"class\": \"active\"}"
fi
