#!/bin/bash

case $1 in
	"")
		echo "Usage:"
		echo "	--save -s	Saves screenshot to file"
		echo "	--copy -c	Copies screenshot to clipboard"
		;;
	"--copy" | "-c")
		OUTPUT=$(~/.local/bin/grimblast copy area)
		RES=$?
		TITLE="Screenshot copied"
		DESC="The selected area has been copied to the clipboard"
		;;
	"--save" | "-s")
		OUTPUT=$(~/.local/bin/grimblast copysave area)
		RES=$?
		TITLE="Screenshot saved"
		DESC="Screenshot has been saved to ~/Pictures/Screenshots"
		;;
esac

if [ $RES -eq 0 ]; then
    notify-send -u normal -a "Screenshot Tool" -i camera "$TITLE" "$DESC"
else
    notify-send -u critical -a "Screenshot Tool" -i dialog-error "Screenshot cancelled" "$OUTPUT"
fi
