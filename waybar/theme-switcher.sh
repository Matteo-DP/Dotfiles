#!/bin/bash
# Switch the Waybar theme: which modules are shown and how the bar looks.
# Colours are separate: they come from ~/.config/hypr/colors/generate-theme.sh,
# which writes colors.css. Every theme's style imports that file, so any
# Waybar theme works with any colour theme.
#
#   themes/<name>/config.jsonc  -> config.jsonc
#   themes/<name>/style.css     -> style.css
#   themes/<name>/modules.jsonc -> modules.jsonc  (optional)
#
# Each theme folder is self-contained. Waybar only accepts absolute "include"
# paths, so a theme's config.jsonc includes ~/.config/waybar/modules.jsonc,
# and this script points that link at the theme's own modules.jsonc.

WAYBAR_DIR="$HOME/.config/waybar"
THEME_DIR="$WAYBAR_DIR/themes"
FILES=("config.jsonc" "style.css")   # required
OPTIONAL_FILES=("modules.jsonc")     # linked if the theme has it, else unlinked

list_themes() {
	local d
	for d in "$THEME_DIR"/*/; do
		[[ -f $d/config.jsonc && -f $d/style.css ]] && basename "$d"
	done
}

# Name of the active theme, from where config.jsonc points.
current_theme() {
	local target
	target=$(readlink "$WAYBAR_DIR/config.jsonc") || { echo "(not a link)"; return; }
	basename "$(dirname "$target")"
}

usage() {
	cat <<EOF
Usage: theme-switcher.sh <THEME> [--no-reload]
       theme-switcher.sh --list | --current

  THEME          Waybar theme to apply (modules + style)
  --list         List themes (* = active)
  --current      Print the active theme
  --no-reload    Change the links but don't restart Waybar
  -h, --help     Show this help

Themes: $(list_themes | tr '\n' ' ')
Colours are set separately with ~/.config/hypr/colors/generate-theme.sh.
EOF
}

restart_waybar() {
	if pgrep -x waybar >/dev/null; then
		pkill -x waybar
		# Wait for the old bar to exit so two bars never overlap.
		for _ in {1..20}; do
			pgrep -x waybar >/dev/null || break
			sleep 0.1
		done
	fi

	if [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]] && command -v hyprctl >/dev/null; then
		hyprctl dispatch 'hl.dsp.exec_cmd("waybar")' >/dev/null
	else
		setsid -f waybar >/dev/null 2>&1
	fi

	sleep 1
	if ! pgrep -x waybar >/dev/null; then
		echo "Warning: Waybar did not start. Run 'waybar' in a terminal to see the error." >&2
		return 1
	fi
	echo "Waybar restarted"
}

THEME=""
RELOAD=1

while [[ $# -gt 0 ]]; do
	case $1 in
		--list)
			active=$(current_theme)
			while read -r name; do
				[[ $name == "$active" ]] && echo "* $name" || echo "  $name"
			done < <(list_themes)
			exit 0
			;;
		--current) current_theme; exit 0 ;;
		--no-reload) RELOAD=0; shift ;;
		-h | --help) usage; exit 0 ;;
		-*) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
		*) THEME=$1; shift ;;
	esac
done

if [[ -z $THEME ]]; then
	usage >&2
	exit 1
fi

# Check everything first, so a typo doesn't leave a half-applied switch.
for file in "${FILES[@]}"; do
	if [[ ! -f $THEME_DIR/$THEME/$file ]]; then
		echo "Error: theme '$THEME' has no $file ($THEME_DIR/$THEME/$file)" >&2
		exit 1
	fi
done
for file in "${FILES[@]}" "${OPTIONAL_FILES[@]}"; do
	if [[ -e $WAYBAR_DIR/$file && ! -L $WAYBAR_DIR/$file ]]; then
		echo "Error: $WAYBAR_DIR/$file is a regular file, not a link." \
			"Move it into a theme folder first so it isn't lost." >&2
		exit 1
	fi
done

for file in "${FILES[@]}" "${OPTIONAL_FILES[@]}"; do
	if [[ -f $THEME_DIR/$THEME/$file ]]; then
		ln -sfn "$THEME_DIR/$THEME/$file" "$WAYBAR_DIR/$file"
		echo "Linked $WAYBAR_DIR/$file -> $THEME_DIR/$THEME/$file"
	elif [[ -L $WAYBAR_DIR/$file ]]; then
		# Don't leave the previous theme's file linked in.
		rm "$WAYBAR_DIR/$file"
		echo "Removed $WAYBAR_DIR/$file (theme has none)"
	fi
done

if ((RELOAD)); then
	restart_waybar
fi
