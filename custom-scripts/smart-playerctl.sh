#!/bin/bash

# Geef voorrang aan spotify, dan firefox

# Gebruik het eerste argument, of 'play-pause' als er geen is
CMD="${1:-play-pause}"

notify_toggle() {
    local player=$1
    local status
    # For some reason the swapping of playing and paused acutally works, change this if necessary.
    status=$(playerctl --player="$player" status 2>/dev/null)
    if [[ "$CMD" == "play-pause" && "$status" == "Paused" ]]; then
        notify-send "Mediaplayer" "Player $player is now playing."
    fi
    if [[ "$CMD" == "play-pause" && "$status" == "Playing" ]]; then
        notify-send "Mediaplayer" "Player $player is paused."
    fi
}

if playerctl --player=spotify status &>/dev/null; then
    playerctl --player=spotify "$CMD" && notify_toggle spotify
elif playerctl --player=firefox status &>/dev/null; then
    playerctl --player=firefox "$CMD" && notify_toggle firefox
else
    playerctl "$CMD"
    if [[ "$CMD" == "play-pause" ]]; then
        # Get the name of the active player
        active_player=$(playerctl -l 2>/dev/null | head -n 1)
        notify_toggle "$active_player"
    fi
fi
