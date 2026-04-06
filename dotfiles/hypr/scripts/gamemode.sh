#!/usr/bin/env bash
#                                      __   
#   ___ ____ ___ _  ___ __ _  ___  ___/ /__ 
#  / _ `/ _ `/  ' \/ -_)  ' \/ _ \/ _  / -_)
#  \_, /\_,_/_/_/_/\__/_/_/_/\___/\_,_/\__/ 
# /___/                                     
# 


archstoso_cache_folder="$HOME/.cache/archstoso/hyprland-dotfiles"
gamemode_monitor="$HOME/.config/hypr/conf/monitors/gamemode.conf"

# Notifications
source "$HOME/.config/archstoso/scripts/archstoso-notification-handler"
APP_NAME="System"
NOTIFICATION_ICON="joystick"


if [ -f $HOME/.config/archstoso/settings/gamemode-enabled ]; then
  if [ -f $archstoso_cache_folder/last_monitor.conf ]; then
    cat $archstoso_cache_folder/last_monitor.conf > $HOME/.config/hypr/conf/monitor.conf
    rm $archstoso_cache_folder/last_monitor.conf
  fi
  if [ -f $archstoso_cache_folder/restart-wpauto ]; then
    rm $archstoso_cache_folder/restart-wpauto
    $HOME/.config/hypr/scripts/wallpaper-automation.sh &
  fi
  hyprctl reload
  rm $HOME/.config/archstoso/settings/gamemode-enabled
  notify_user --a "${APP_NAME}" \
            --i "${NOTIFICATION_ICON}" \
            --s "Gamemode deactivated" \
            --m "Animations and blur are now enabled."
else
  if [ -f $gamemode_monitor ]; then
    cat $HOME/.config/hypr/conf/monitor.conf > $archstoso_cache_folder/last_monitor.conf
    echo "source = $gamemode_monitor" > $HOME/.config/hypr/conf/monitor.conf
  fi
  if [ -f $archstoso_cache_folder/wallpaper-automation ]; then
    touch $archstoso_cache_folder/restart-wpauto
    $HOME/.config/hypr/scripts/wallpaper-automation.sh
  fi
  hyprctl --batch "\
    keyword animations:enabled 0;\
    keyword decoration:shadow:enabled 0;\
    keyword decoration:blur:enabled 0;\
    keyword general:gaps_in 0;\
    keyword general:gaps_out 0;\
    keyword general:border_size 1;\
    keyword decoration:active_opacity 1;\
    keyword decoration:inactive_opacity 1;\
    keyword decoration:fullscreen_opacity 1;\
    keyword decoration:rounding 0"
  touch $HOME/.config/archstoso/settings/gamemode-enabled
  notify_user --a "${APP_NAME}" \
          --i "${NOTIFICATION_ICON}" \
          --s "Gamemode activated" \
          --m "Animations and blur are now disabled."
fi