#!/bin/bash

read -r _ _ wallpaper <<< "$(grep "wallpaper" ~/.config/waypaper/config.ini)"
echo "$wallpaper" > ~/.config/wallpaper/current-wallpaper
wallpaper_expanded="${wallpaper/#\~/$HOME}"
echo "\$wallpaper=$wallpaper_expanded" > ~/.config/wallpaper/wallpaper-source-hyprlock
wal -i "$wallpaper_expanded"
~/.config/waybar/launch.sh
