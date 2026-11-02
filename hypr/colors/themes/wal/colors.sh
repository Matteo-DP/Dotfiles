
### Special
export COLOR_BACKGROUND=$(grep 'background=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR_FOREGROUND=$(grep 'foreground=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR_CURSOR=$(grep 'cursor=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")

### Basic 16 Terminal Colors
export COLOR0=$(grep 'color0=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR1=$(grep 'color1=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR2=$(grep 'color2=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR3=$(grep 'color3=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR4=$(grep 'color4=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR5=$(grep 'color5=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR6=$(grep 'color6=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR7=$(grep 'color7=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")

export COLOR8=$(grep 'color8=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR9=$(grep 'color9=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR10=$(grep 'color10=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR11=$(grep 'color11=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR12=$(grep 'color12=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR13=$(grep 'color13=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR14=$(grep 'color14=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")
export COLOR15=$(grep 'color15=' ~/.cache/wal/colors.sh | cut -d'=' -f2 | sed "s/'//g")

export COLOR_ACCENT=$COLOR8
export COLOR_WARNING=$COLOR11
export COLOR_ERROR=$COLOR12
export COLOR_SUCCESS=$COLOR10