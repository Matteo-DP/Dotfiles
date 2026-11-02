#!/bin/bash
export SYMLINK_TARGET=~/.config/hypr/colors/current-theme/hypr.conf
export SYMLINK_SOURCE=~/.config/hypr/colors.conf
export SYMLINK_TARGET_LUA=~/.config/hypr/colors/current-theme/hypr.lua
export SYMLINK_SOURCE_LUA=~/.config/hypr/colors.lua

hook_generate_target() {
	cat > $SYMLINK_TARGET <<EOF
# Auto-generated from colors.sh (Hyprland style)
# Colors
\$COLOR_BACKGROUND=${COLOR_BACKGROUND#"#"}
\$COLOR_FOREGROUND=${COLOR_FOREGROUND#"#"}
\$COLOR_CURSOR=${COLOR_CURSOR#"#"}
\$COLOR0=${COLOR0#"#"}
\$COLOR1=${COLOR1#"#"}
\$COLOR2=${COLOR2#"#"}
\$COLOR3=${COLOR3#"#"}
\$COLOR4=${COLOR4#"#"}
\$COLOR5=${COLOR5#"#"}
\$COLOR6=${COLOR6#"#"}
\$COLOR7=${COLOR7#"#"}
\$COLOR8=${COLOR8#"#"}
\$COLOR9=${COLOR9#"#"}
\$COLOR10=${COLOR10#"#"}
\$COLOR11=${COLOR11#"#"}
\$COLOR12=${COLOR12#"#"}
\$COLOR13=${COLOR13#"#"}
\$COLOR14=${COLOR14#"#"}
\$COLOR15=${COLOR15#"#"}
\$COLOR_ACCENT=${COLOR_ACCENT#"#"}
\$COLOR_WARNING=${COLOR_WARNING#"#"}
\$COLOR_ERROR=${COLOR_ERROR#"#"}
\$COLOR_SUCCESS=${COLOR_SUCCESS#"#"}
EOF

	# Lua version for hyprland.lua (hyprlock still uses the hyprlang file above)
	cat > $SYMLINK_TARGET_LUA <<EOF
-- Auto-generated from colors.sh (Hyprland Lua style)
return {
	COLOR_BACKGROUND = "${COLOR_BACKGROUND#"#"}",
	COLOR_FOREGROUND = "${COLOR_FOREGROUND#"#"}",
	COLOR_CURSOR = "${COLOR_CURSOR#"#"}",
	COLOR0 = "${COLOR0#"#"}",
	COLOR1 = "${COLOR1#"#"}",
	COLOR2 = "${COLOR2#"#"}",
	COLOR3 = "${COLOR3#"#"}",
	COLOR4 = "${COLOR4#"#"}",
	COLOR5 = "${COLOR5#"#"}",
	COLOR6 = "${COLOR6#"#"}",
	COLOR7 = "${COLOR7#"#"}",
	COLOR8 = "${COLOR8#"#"}",
	COLOR9 = "${COLOR9#"#"}",
	COLOR10 = "${COLOR10#"#"}",
	COLOR11 = "${COLOR11#"#"}",
	COLOR12 = "${COLOR12#"#"}",
	COLOR13 = "${COLOR13#"#"}",
	COLOR14 = "${COLOR14#"#"}",
	COLOR15 = "${COLOR15#"#"}",
	COLOR_ACCENT = "${COLOR_ACCENT#"#"}",
	COLOR_WARNING = "${COLOR_WARNING#"#"}",
	COLOR_ERROR = "${COLOR_ERROR#"#"}",
	COLOR_SUCCESS = "${COLOR_SUCCESS#"#"}",
}
EOF
	ln -sf $SYMLINK_TARGET_LUA $SYMLINK_SOURCE_LUA
}

hook_post_generate() {
	hyprctl reload 1>/dev/null
}

export -f hook_generate_target
export -f hook_post_generate
