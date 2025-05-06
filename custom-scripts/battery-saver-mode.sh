#!/bin/bash

# Spaces will be interpreted as a diff option --> globbing enabled
TARGETS=("--user onedrive.service")

STOPPED_SERVICES=()

log_error() {
    msg=$1
    echo $msg >&2
    notify-send -u critical "Battery saver script" "$msg"
}

restart_services () {
    echo "Exiting... Restarting stopped services"
    for service in "${STOPPED_SERVICES[@]}"; do
        if systemctl start $service; then
            echo "Restarted $service"
        else
            msg="Failed to restart $service"
            log_error $msg
        fi
    done
}

trap restart_services EXIT

while true; do
    for target in "${TARGETS[@]}"; do
        if systemctl is-active --quiet $target; then
            echo "Target $target is active. Stopping..."
            if systemctl stop $target; then
                echo "Stoppped $target"
                STOPPED_SERVICES+=("$target")
            else
                msg="Failed to stop $target"
                log_error $msg
            fi
        fi
    done
    sleep 10
done

