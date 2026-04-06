#!/usr/bin/env bash
# Waybar Theme Switcher (simplified for 2 themes)

themes_path="$HOME/.config/waybar/themes"

# Build theme list from available themes
listThemes=""
listNames=""
listNames2=""

sleep 0.2
options=$(find $themes_path -maxdepth 2 -type d)
for value in $options; do
    if [ ! $value == "$themes_path" ]; then
        if [ $(find $value -maxdepth 1 -type d | wc -l) = 1 ]; then
            result=$(echo $value | sed "s#$HOME/.config/waybar/themes/#/#g")
            IFS='/' read -ra arrThemes <<<"$result"
            listThemes[${#listThemes[@]}]="/${arrThemes[1]};$result"
            if [ -f $themes_path$result/config.sh ]; then
                source $themes_path$result/config.sh
                listNames+="$theme_name\n"
                listNames2+="$theme_name~"
            else
                listNames+="/${arrThemes[1]};$result\n"
                listNames2+="/${arrThemes[1]};$result~"
            fi
        fi
    fi
done

# Use Walker to select theme
listNames=${listNames::-2}
choice=$(echo -e "$listNames" | $HOME/.config/walker/launch.sh -d -i -N -H --height 400 -p "Search Theme")

IFS="~"
input=$listNames2
read -ra array <<<"$input"

# Apply selected theme
if [ "$choice" ]; then
    echo "Loading waybar theme..."
    echo "${listThemes[$choice + 1]}" >~/.config/archstoso/settings/waybar-theme.sh
    ~/.config/waybar/launch.sh
fi
