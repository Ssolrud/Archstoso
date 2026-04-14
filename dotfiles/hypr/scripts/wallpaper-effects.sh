#!/usr/bin/env bash
# __        ______    _____  __  __           _
# \ \      / /  _ \  | ____|/ _|/ _| ___  ___| |_ ___
#  \ \ /\ / /| |_) | |  _| | |_| |_ / _ \/ __| __/ __|
#   \ V  V / |  __/  | |___|  _|  _|  __/ (__| |_\__ \
#    \_/\_/  |_|     |_____|_| |_|  \___|\___|\__|___/
#

# Notifications
source "$HOME/.config/archstoso/scripts/archstoso-notification-handler"
APP_NAME="Waypaper"
NOTIFICATION_ICON="preferences-desktop-wallpaper-symbolic"

archstoso_cache_folder="$HOME/.cache/archstoso/hyprland-dotfiles"

# Get current wallpaper
cache_file="$archstoso_cache_folder/current_wallpaper"

if [ $1 == "reload" ]; then
    # Releod wallpaper with current effect
    waypaper --wallpaper $(cat $cache_file)
else
    options="$(ls ~/.config/hypr/effects/wallpaper/)\noff"
    choice=$(echo -e "$options" | fuzzel --dmenu -p "Wallpaper Effect: ")
    if [ ! -z $choice ]; then
        echo "$choice" >~/.config/archstoso/settings/wallpaper-effect.sh

        notify_user \
            --a "${APP_NAME}" \
            --i "${NOTIFICATION_ICON}" \
            --s "Wallpaper" \
            --m "Changing Wallpaper Effect to " "$choice."

        waypaper --wallpaper $(cat $cache_file)
    fi
fi
