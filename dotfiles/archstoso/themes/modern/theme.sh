#!/usr/bin/env bash
# ArchStoso Theme: Modern
# Applies the modern preset: Waybar modern theme, border-2, Walker modern skin,
# SwayNC modern style, Wlogout modern style.

# Ensure settings directory exists
mkdir -p "$HOME/.config/archstoso/settings"

# Set waybar theme (format: THEME_FOLDER;VARIATION_FOLDER)
# launch.sh resolves: ~/.config/waybar/themes/modern/  and  ~/.config/waybar/themes/modern/default/
echo "modern;modern/default" > "$HOME/.config/archstoso/settings/waybar-theme.sh"
"$HOME/.config/waybar/launch.sh" &

# Set swaync theme
echo '@import "themes/modern/style.css";' > "$HOME/.config/swaync/style.css"
swaync-client -rs

# Set wlogout theme
echo '@import "themes/modern/style.css";' > "$HOME/.config/wlogout/style.css"

# Set Walker theme
echo 'modern' > "$HOME/.config/archstoso/settings/walker-theme"

# Set window border (border-2: colored dual-gradient border)
echo 'source = ~/.config/hypr/conf/windows/border-2.conf' > "$HOME/.config/hypr/conf/window.conf"

# Reload Hyprland to apply border change
hyprctl reload

echo ":: Theme set to Modern"
