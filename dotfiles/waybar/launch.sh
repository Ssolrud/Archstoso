#!/usr/bin/env bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#

# Prevent duplicate launches
exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# Quit all running waybar instances
killall waybar || true
pkill waybar || true
sleep 0.5

# Default theme: /THEMEFOLDER;/VARIATION
default_theme="/modern;/modern/default"

# Get current theme from settings
if [ -f ~/.config/archstoso/settings/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/archstoso/settings/waybar-theme.sh)
else
    touch ~/.config/archstoso/settings/waybar-theme.sh
    echo "$default_theme" >~/.config/archstoso/settings/waybar-theme.sh
    themestyle=$default_theme
fi

IFS=';' read -ra arrThemes <<<"$themestyle"
echo ":: Theme: ${arrThemes[0]}"

if [ ! -f ~/.config/waybar/themes${arrThemes[1]}/style.css ]; then
    themestyle=$default_theme
    IFS=';' read -ra arrThemes <<<"$themestyle"
fi

# Loading the configuration
config_file="config"
style_file="style.css"

# Custom overrides
if [ -f ~/.config/waybar/themes${arrThemes[0]}/config-custom ]; then
    config_file="config-custom"
fi
if [ -f ~/.config/waybar/themes${arrThemes[1]}/style-custom.css ]; then
    style_file="style-custom.css"
fi

# Launch waybar if not disabled
if [ ! -f $HOME/.config/archstoso/settings/waybar-disabled ]; then
    HYPRLAND_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
    HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" waybar -c ~/.config/waybar/themes${arrThemes[0]}/$config_file -s ~/.config/waybar/themes${arrThemes[1]}/$style_file &
else
    echo ":: Waybar disabled"
fi

flock -u 200
exec 200>&-
