#!/bin/bash

# Usage: ./run_with_notification.sh [mode]

# Check if the required environment variables are set
if [ -z "$RPI_IP" ]; then
    echo "Error: RPI_IP environment variable is not set."
    echo "Set RPI_IP to the Raspberry Pi's IP address."
    exit 1
fi

if [ -z "$RPI_API_KEY" ]; then
    echo "Error: RPI_API_KEY environment variable is not set."
    echo "Set RPI_API_KEY to the API key for authentication."
    exit 1
fi

# Capture the mode argument
if [ -z "$1" ]; then
    echo "Error: No mode argument provided. Use '0' for toggle or '1' for state."
    exit 1
fi

OUTPUT=$("$HOME/.config/custom-scripts/waybar-light/waybar-light.out" "$RPI_IP" "$1" "$RPI_API_KEY" 2>&1)
EXIT_CODE=$?

# Echo the output to the terminal
# echo "$OUTPUT"

TITLE=""

if [[ "$1" == "1" ]]; then
    TITLE="state"
else
    TITLE="toggled"
fi

# Send a notification with the output
if [ $EXIT_CODE -eq 0 ]; then
    # notify-send "Light $TITLE" "$OUTPUT"
    notify-send "Light $TITLE" "$OUTPUT"
else
    notify-send -u critical "Script Error" "$OUTPUT"
fi

# Exit with the same code as the binary
exit $EXIT_CODE
