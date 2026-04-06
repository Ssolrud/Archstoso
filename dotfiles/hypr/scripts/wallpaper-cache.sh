#!/usr/bin/env bash

# Notifications
source "$HOME/.config/archstoso/scripts/archstoso-notification-handler"

archstoso_cache_folder="$HOME/.cache/archstoso/hyprland-dotfiles"
generated_versions="$archstoso_cache_folder/wallpaper-generated"
rm $generated_versions/*
echo ":: Wallpaper cache cleared"
notify_user \
        --a "System" \
        --m "Wallpaper cache cleared"
