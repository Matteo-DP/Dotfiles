#!/bin/bash
THEME=$1
shift

while [[ $# -gt 0 ]]; do
	case $1 in
		"--hooks")
			IFS=, read -ra HOOKS <<< "$2"
			shift
			;;
		*)
		shift
		;;
	esac
done

echo_usage() {
	local hook_str
	while read line; do
		hook_str+="${line%%.sh}, "
	done < <(ls "$HOME/.config/hypr/colors/hooks")
	local theme_str
	while read line; do
		theme_str+="${line%%.sh}, "
	done < <(ls "$HOME/.config/hypr/colors/themes")
	echo "Usage: ./generate-theme.sh <THEME-NAME>"
	echo "Available themes:"
	echo "${theme_str%%, }"
	echo "Optional flags:"
	echo "  --hooks <hook1,hook2,...>"
	echo "	Specify hooks to run. If omitted, run all hooks"
	echo "	Available hooks:"
	echo "	${hook_str%%, }"
}

if [[ -z $THEME ]]; then
	echo "No theme selected" 1>&2
	echo_usage
	exit 1
fi

COLORS_PATH="$HOME/.config/hypr/colors/themes/$THEME/colors.sh"

if [[ ! -f $COLORS_PATH ]]; then
	echo "File $COLORS_PATH not found" 1>&2
	echo_usage
	exit 1
fi

SYMLINK_TARGET="$HOME/.config/hypr/colors/current-theme/colors.sh"

if [[ -f $SYMLINK_TARGET ]] || [[ -L $SYMLINK_TARGET ]]; then
	rm $SYMLINK_TARGET
fi

ln -s "$COLORS_PATH" "$SYMLINK_TARGET"
echo "Symlink created: $COLORS_PATH → $SYMLINK_TARGET"

echo "--- Executing hooks ---"
for filename in $HOME/.config/hypr/colors/hooks/*.sh; do
	name=$(basename "$filename" .sh)
	if [[ ! -z $HOOKS ]]; then
		if [[ ! " ${HOOKS[@]} " =~ " $name " ]]; then
			echo "Skipping hook $name"
			continue
		fi
	fi
	$HOME/.config/hypr/colors/utils/hook-framework.sh "$COLORS_PATH" "$filename" "$name"
	echo "[$name] DONE: Executed hook $filename"
done

echo "--- All done ---"
