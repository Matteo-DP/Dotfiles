export SYMLINK_TARGET=~/.config/hypr/colors/current-theme/kitty.conf
export SYMLINK_SOURCE=~/.config/kitty/themes/mytheme.conf

hook_generate_target() {
cat > $SYMLINK_TARGET <<EOF
foreground $COLOR_FOREGROUND
cursor     $COLOR_CURSOR

color0  $COLOR0
color1  $COLOR1
color2  $COLOR2
color3  $COLOR3
color4  $COLOR4
color5  $COLOR5
color6  $COLOR6
color7  $COLOR7
color8  $COLOR8
color9  $COLOR9
color10 $COLOR10
color11 $COLOR11
color12 $COLOR12
color13 $COLOR13
color14 $COLOR14
color15 $COLOR15
EOF
}

hook_post_generate() {
	kitty @ set-colors "$SYMLINK_SOURCE"
}

export -f hook_generate_target
export -f hook_post_generate
