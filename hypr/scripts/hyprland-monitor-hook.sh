#!/bin/sh

handle() {
  case $1 in
	  monitoraddedv2*)
		  echo "Running monitor added hook"
		  hyprctl dispatch "hl.dsp.exec_cmd('$HOME/.config/hypr/scripts/swww/restore.sh')"
		  ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
