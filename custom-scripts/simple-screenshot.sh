#!/bin/bash

OUTPUT=$(grimblast copy area)

if [ $? -eq 0 ]; then
    notify-send -u normal -a "Screenshot Tool" -i camera "Screenshot Copied" "The selected area has been copied to the clipboard."
else
    notify-send -u critical -a "Screenshot Tool" -i dialog-error "Screenshot cancelled" "$OUTPUT"
fi
