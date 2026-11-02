export SYMLINK_TARGET=~/.config/hypr/colors/current-theme/waybar.css
export SYMLINK_SOURCE=~/.config/waybar/colors.css

hook_generate_target() {
    cat > $SYMLINK_TARGET <<EOF
/* Auto-generated from colors.sh (GTK3 style) */
@define-color color_background $COLOR_BACKGROUND;   /* background */
@define-color color_foreground $COLOR_FOREGROUND;   /* foreground */
@define-color color_cursor $COLOR_CURSOR;   /* cursor */

@define-color color0 $COLOR0;   /* black */
@define-color color1 $COLOR1;   /* red */
@define-color color2 $COLOR2;   /* green */
@define-color color3 $COLOR3;   /* yellow */
@define-color color4 $COLOR4;   /* blue */
@define-color color5 $COLOR5;   /* magenta */
@define-color color6 $COLOR6;   /* cyan */
@define-color color7 $COLOR7;   /* white */

@define-color color8 $COLOR8;   /* bright black */
@define-color color9 $COLOR9;   /* bright red */
@define-color color10 $COLOR10;   /* bright green */
@define-color color11 $COLOR11;   /* bright yellow */
@define-color color12 $COLOR12;   /* bright blue */
@define-color color13 $COLOR13;   /* bright magenta */
@define-color color14 $COLOR14;   /* bright cyan */
@define-color color15 $COLOR15;   /* bright white */

@define-color color_accent $COLOR_ACCENT;   /* accent */
@define-color color_warning $COLOR_WARNING;   /* warning */
@define-color color_error $COLOR_ERROR;   /* error */
@define-color color_success $COLOR_SUCCESS;   /* success */
EOF
}

hook_post_generate() {
    hyprctl dispatch 'hl.dsp.exec_cmd("killall waybar")' && hyprctl dispatch 'hl.dsp.exec_cmd("waybar")'
}

export -f hook_generate_target
export -f hook_post_generate