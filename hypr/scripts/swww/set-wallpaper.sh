#!/bin/bash
FP=$1
shift
disable_hooks=0
while [[ ! -z $1 ]]; do
	case $1 in
		"--disable-hooks")
			disable_hooks=1
			echo "Disabled post wallpaper hooks"
			shift
			;;
		*)
			shift
			;;
	esac
done

set_colors_wal_hook() {
	echo "Setting theme colors to wal"
	$HOME/.config/hypr/scripts/wal.sh && $HOME/.config/hypr/colors/generate-theme.sh wal
}

CACHE_PATH=~/.cache/wallpaper/current_wallpaper
SYMLINK_PATH=~/.cache/wallpaper/current_wallpaper_symlink
TRANSITION=$(~/.config/hypr/scripts/swww/get-transition.sh)

if [[ -z $FP ]]; then
	echo "Usage: set-wallpaper.sh [path] [args]"
	echo "args:"
	echo "	--disable-hooks		Don't run post wallpaper hooks. Disables color palette changes"
	exit 1
fi

if [[ ! -a $FP ]]; then
	echo "File $FP not found." 1>&2
	exit 1
fi

REAL_FP=$(realpath "$FP")

swww img --resize crop $REAL_FP $TRANSITION
echo "$REAL_FP" > "$CACHE_PATH"
if [[ -h "$SYMLINK_PATH" ]]; then
	unlink "$SYMLINK_PATH"
fi
ln -sf "$REAL_FP" "$SYMLINK_PATH"
[ "$disable_hooks" -eq 0 ] && set_colors_wal_hook

