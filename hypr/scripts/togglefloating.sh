# get the class and floating status of the active window
is_floating=$(hyprctl activewindow | grep '^	floating:' | awk '{print $2}')

# if the window is already floating, toggle it back to tiled
if [[ $is_floating == "1" ]]; then
    hyprctl dispatch togglefloating
    exit 0
fi

# resize and float the active window based on its class
hyprctl dispatch togglefloating
hyprctl dispatch resizeactive exact 65% 70%
hyprctl dispatch centerwindow
