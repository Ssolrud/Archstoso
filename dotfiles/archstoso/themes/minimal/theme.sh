#!/usr/bin/env bash
# ArchStoso Theme: Minimal
# Applies the minimal preset: Waybar minimal theme, default border, Walker minimal skin,
# SwayNC minimal style, Wlogout minimal style.

# Ensure settings directory exists
mkdir -p "$HOME/.config/archstoso/settings"

# Set waybar theme (format: THEME_FOLDER;VARIATION_FOLDER)
# launch.sh resolves: ~/.config/waybar/themes/minimal/  and  ~/.config/waybar/themes/minimal/default/
echo "/minimal;/minimal" > "$HOME/.config/archstoso/settings/waybar-theme.sh"
"$HOME/.config/waybar/launch.sh" &

# Set swaync theme
echo '@import "themes/minimal/style.css";' > "$HOME/.config/swaync/style.css"
swaync-client -rs

# Set wlogout theme
echo '@import "themes/minimal/style.css";' > "$HOME/.config/wlogout/style.css"

# Set Walker theme
echo 'minimal' > "$HOME/.config/archstoso/settings/walker-theme"

# Set window border (default: single-color border, lighter weight)
echo 'source = ~/.config/hypr/conf/windows/default.conf' > "$HOME/.config/hypr/conf/window.conf"

# Reload Hyprland to apply border change
hyprctl reload

echo ":: Theme set to Minimal"
