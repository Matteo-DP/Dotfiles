#!/bin/bash
export SOURCE=$1
export HOOK=$2
export NAME=${3:-"Generic name"}
if [[ -z $SOURCE ]]; then
	echo "$NAME: No colors.sh found" 1>&2
	exit 1
fi
source $SOURCE # source colors file

if [[ -z $HOOK ]] || [[ ! -f $HOOK ]]; then
    echo "[$NAME] No hook.sh found" 1>&2
    exit 1
fi
source $HOOK

#SYMLINK_TARGET defined in hook.sh
#SYMLINK_SOURCE defined in hook.sh

if [[ -z $SYMLINK_TARGET ]] || [[ -z $SYMLINK_SOURCE ]]; then
    echo "[$NAME] Error: SYMLINK_TARGET or SYMLINK_SOURCE not defined." 1>&2
    exit 1
fi

hook_generate_target
echo "[$NAME] Theme generated at $SYMLINK_TARGET"

if [[ -L "$SYMLINK_SOURCE" ]] || [[ -f "$SYMLINK_SOURCE" ]]; then
	rm "$SYMLINK_SOURCE"
fi

ln -s "$SYMLINK_TARGET" "$SYMLINK_SOURCE" 1>/dev/null
echo "[$NAME] Created symlink: $SYMLINK_SOURCE -> $SYMLINK_TARGET"

hook_post_generate
