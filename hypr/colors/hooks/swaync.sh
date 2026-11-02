export SYMLINK_TARGET=~/.config/hypr/colors/current-theme/swaync.css
export SYMLINK_SOURCE=~/.config/swaync/colors.css

# "#rrggbb" -> "r, g, b"
rgb() {
    local hex=${1#\#}
    printf "%d, %d, %d" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
}

hook_generate_target() {
cat > $SYMLINK_TARGET <<CSS
/* Auto-generated from colors.sh */
:root {
  --cc-bg: rgba($(rgb $COLOR_BACKGROUND), 0.96);
  --noti-border-color: $COLOR_ACCENT;
  --noti-bg: $(rgb $COLOR_BACKGROUND);
  --noti-bg-alpha: 0.92;
  --noti-bg-darker: $COLOR0;
  --noti-bg-hover: $COLOR0;
  --noti-bg-focus: rgba($(rgb $COLOR8), 0.6);
  --noti-close-bg: $COLOR0;
  --noti-close-bg-hover: $COLOR8;
  --text-color: $COLOR_FOREGROUND;
  --text-color-disabled: $COLOR8;
  --bg-selected: $COLOR_ACCENT;
}

.notification-row .notification-background .notification.critical {
  border: 1px solid $COLOR_ERROR;
}
CSS
}

hook_post_generate() {
    # Only reload when running; the client blocks if swaync isn't up
    if pgrep -x swaync >/dev/null; then
        timeout 2 swaync-client --reload-css >/dev/null 2>&1
    fi
}
