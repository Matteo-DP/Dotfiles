#!/bin/bash
CACHE_DIR=~/.cache/wallpaper
CACHE_FILE=current_wallpaper
CACHE_PATH="${CACHE_DIR}/${CACHE_FILE}"
SET_PATH=~/.config/hypr/scripts/swww/set-wallpaper.sh

if [[ ! -d $CACHE_DIR ]]; then
	mkdir "$CACHE_DIR"
	echo "Created $CACHE_DIR"
fi
if [[ ! -f $CACHE_PATH ]]; then
	touch "$CACHE_PATH"
	echo "Created $CACHE_PATH"
fi

LAST_WALLPAPER=$(cat "$CACHE_PATH")
$SET_PATH $LAST_WALLPAPER
