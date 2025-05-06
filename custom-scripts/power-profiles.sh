#!/bin/bash

log_error() {
    msg=$1
    notify-send -u critical "Power profile error" "$msg"
    echo $msg >&2
}

log_info() {
    msg=$1
    notify-send "Power profile" "$msg"
    echo $msg
}

if [[ -z $1 ]]; then
    log_error "Please specify get | set"
    exit 1
fi

arg=$1
shift

if [[ $arg == "get" ]]; then
    if tlp-stat -s | grep "Mode" | grep "battery" &>/dev/null; then
        if systemctl --user is-active --quiet battery-saver.service; then
            echo "battery-saver"
        else
            echo "balanced"
        fi
    else
        echo "performance"
    fi
    exit 0
fi

if [[ -z $1 ]]; then
    log_error "Please specify a power profile: performance, balanced, battery-saver"
    exit 1
fi

profile=$1

auto() {
    if pkexec tlp start &>/dev/null && systemctl --user --quiet stop battery-saver.service; then
        log_info "Profile 'automatic' applied"
    else
        log_error "Profile 'automatic' not applied"
    fi
}

performance() {
    if pkexec tlp ac &>/dev/null && systemctl --user --quiet stop battery-saver.service; then
        log_info "Profile 'performance' applied"
    else
        log_error "Profile 'performance' not applied"
    fi
}

balanced() {
    if pkexec tlp bat &>/dev/null && systemctl --user --quiet stop battery-saver.service; then
        log_info "Profile 'balanced' applied"
    else
        log_error "Profile 'balanced' not applied"
    fi
}

battery_saver() {
    if pkexec tlp bat &>/dev/null && systemctl --user start battery-saver.service; then
        log_info "Profile 'battery-saver' applied"
    else
        log_error "Profile 'battery-saver' not applied"
    fi
}

case $profile in
    "performance")
        performance
        ;;
    "balanced")
        balanced
        ;;
    "battery-saver")
        battery_saver
        ;;
    "automatic")
        auto
        ;;
    *)
        log_error "Profile $profile unrecognised"
        exit 1
        ;;
esac

exit 0
