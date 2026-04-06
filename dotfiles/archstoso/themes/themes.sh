#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# -----------------------------------------------------
# Themes
# Walker is the only supported launcher in ArchStoso
# -----------------------------------------------------
if ! command -v walker > /dev/null 2>&1; then
    echo "ERROR: walker is not installed. Cannot open theme picker." >&2
    exit 1
fi

THEME_OPTIONS=$(find "$SCRIPT_DIR" -maxdepth 1 -mindepth 1 -type d | awk -F/ '{ print $NF }' | sort)

# -----------------------------------------------------
# Start Launcher (Walker only)
# -----------------------------------------------------
selected_theme=$($HOME/.config/walker/launch.sh -d -N -H -p "Search Theme" <<<"$THEME_OPTIONS")

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
