#!/bin/bash

# Script to set wallpaper and restart hyprswitch on new monitor connected

sleep 1
hyprctl --instance 0 dispatch exec -- waypaper --restore
hyprctl --instance 0 dispatch exec /usr/home/nekros/.config/hyprswitch/launch.sh
