export SYMLINK_TARGET=~/.config/hypr/colors/current-theme/mako
export SYMLINK_SOURCE=~/.config/mako/colors

hook_generate_target() {
cat > $SYMLINK_TARGET <<EOF
background-color=$COLOR_BACKGROUND
text-color=$COLOR_FOREGROUND
border-color=$COLOR_ACCENT
EOF
}

hook_post_generate() {
    killall mako
    hyprctl dispatch 'hl.dsp.exec_cmd("mako")' &
}