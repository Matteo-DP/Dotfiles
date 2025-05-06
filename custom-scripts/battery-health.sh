#!/bin/bash
#                __                                                 __                  
#   ____   ____ |  | _________  ____  ______   ____  __ __  _______/  |_  ____   _____  
#  /    \_/ __ \|  |/ /\_  __ \/  _ \/  ___/ _/ ___\|  |  \/  ___/\   __\/  _ \ /     \ 
# |   |  \  ___/|    <  |  | \(  <_> )___ \  \  \___|  |  /\___ \  |  | (  <_> )  Y Y  \
# |___|  /\___  >__|_ \ |__|   \____/____  >  \___  >____//____  > |__|  \____/|__|_|  /
#      \/     \/     \/                  \/       \/           \/                    \/  

#echo "
#                __                         
#   ____   ____ |  | _________  ____  ______
#  /    \_/ __ \|  |/ /\_  __ \/  _ \/  ___/
# |   |  \  ___/|    <  |  | \(  <_> )___ \ 
# |___|  /\___  >__|_ \ |__|   \____/____  >
#      \/     \/     \/                  \/        
#"

watch /usr/bin/upower -i /org/freedesktop/UPower/devices/battery_BAT0

#echo "Press Enter or Escape to exit the script. Press r to refresh"
#while true; do
#    read -rsn1 key # Read a single character silently
#    if [[ -z "$key" ]]; then
#        # If Enter is pressed (key is empty)
#        echo "Enter key pressed. Exiting..."
#        break
#    elif [[ "$key" == $'\e' ]]; then
#        # If Escape key is pressed
#        echo "Escape key pressed. Exiting..."
#        break
#    elif [[ "$key" == $'r' ]]; then
#        clear
#        echo "Refreshing info"
#        ~/.config/custom-scripts/battery-health.sh
#        break
#    fi
#done
