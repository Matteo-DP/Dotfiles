paths=("config.jsonc" "style.css")

THEME=$1

if [[ -z $THEME ]]; then
	echo "Usage: theme-switcher.sh [theme]"
	exit 1
fi

for path in "${paths[@]}"; do
	if [[ -f $path ]]; then 
		rm ~/.config/waybar/"$path" 
	fi
	ln -s ~/.config/waybar/themes/"$THEME"/"$path" ~/.config/waybar/"$path"
done
