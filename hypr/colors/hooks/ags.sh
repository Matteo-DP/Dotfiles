export SYMLINK_TARGET=~/.config/hypr/colors/current-theme/ags.css
export SYMLINK_SOURCE=~/.config/ags/colors.css

# "#rrggbb" -> "r, g, b"
rgb() {
    local hex=${1#\#}
    printf "%d, %d, %d" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
}

hook_generate_target() {
cat > $SYMLINK_TARGET <<CSS
/* Auto-generated from colors.sh - used by the AGS on-screen display */
:root {
  --osd-bg: rgba($(rgb $COLOR_BACKGROUND), 0.85);
  --osd-bg-solid: $COLOR_BACKGROUND;
  --osd-fg: $COLOR_FOREGROUND;
  --osd-dim: $COLOR8;
  --osd-track: $COLOR0;
  --osd-border: rgba($(rgb $COLOR_ACCENT), 0.18);
  --osd-accent: $COLOR_ACCENT;
  --osd-accent-soft: rgba($(rgb $COLOR_ACCENT), 0.12);
  --osd-warning: $COLOR_WARNING;
  --osd-error: $COLOR_ERROR;
  --osd-error-soft: rgba($(rgb $COLOR_ERROR), 0.16);
}
CSS
}

hook_post_generate() {
    # Only reload when the OSD is running
    timeout 2 ags request -i osd reload-css >/dev/null 2>&1 || true
}
