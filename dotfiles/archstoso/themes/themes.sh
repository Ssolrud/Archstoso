#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# -----------------------------------------------------
# Themes
# -----------------------------------------------------
THEME_OPTIONS=$(find "$SCRIPT_DIR" -maxdepth 1 -mindepth 1 -type d | awk -F/ '{ print $NF }' | sort)

# -----------------------------------------------------
# Select theme via fuzzel dmenu
# -----------------------------------------------------
selected_theme=$(echo "$THEME_OPTIONS" | fuzzel --dmenu -p "Select theme: ")

# -----------------------------------------------------
# Source selected theme
# -----------------------------------------------------
if [ -n "$selected_theme" ]; then
    theme_script="$HOME/.config/archstoso/themes/$selected_theme/theme.sh"
    if [ -f "$theme_script" ]; then
        # shellcheck source=/dev/null
        source "$theme_script"
    else
        echo "ERROR: Theme script not found: $theme_script" >&2
        exit 1
    fi
fi
