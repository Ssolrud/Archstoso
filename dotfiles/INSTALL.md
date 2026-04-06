# ArchStoso — Install Guide

A Hyprland desktop environment for Arch Linux.

## Prerequisites

- A running Arch Linux installation (base install complete)
- An internet connection
- A non-root user with `sudo` privileges
- `git` installed (`sudo pacman -S git`)

## Quick Start

```bash
git clone https://github.com/daystoso/ArchStoso.git
cd ArchStoso/dotfiles
chmod +x install.sh
./install.sh
```

That's it. The installer handles everything else automatically.

## What the Installer Does

1. **Checks your system** — confirms Arch Linux and non-root user
2. **Sets up an AUR helper** — detects `yay` or `paru`, installs one if neither is found
3. **Installs packages** — 66 pacman packages + 7 AUR packages (skips already-installed ones)
4. **Backs up existing configs** — saves your current `~/.config/` directories to `~/.config-backup-archstoso-TIMESTAMP/`
5. **Copies dotfiles** — installs all configs to `~/.config/`
6. **Sets environment variables** — adds `BROWSER`, `TERMINAL`, `EDITOR`, `FILE_MANAGER` to `~/.bashrc`
7. **Makes scripts executable** — sets permissions on all ArchStoso and Hyprland scripts

## Dry Run

Preview what the installer will do without making any changes:

```bash
./install.sh --dry-run
```

## After Installation

1. Log out of your current session
2. At your display manager (SDDM, ly, etc.), select **Hyprland**
   - Or from a TTY: `uwsm start hyprland`
3. Hyprland will launch with the default wallpaper and the **modern** theme

## Key Bindings (Defaults)

| Keys | Action |
|------|--------|
| `SUPER + Return` | Open terminal (Kitty) |
| `SUPER + D` | Open launcher (Walker) |
| `SUPER + Q` | Close window |
| `SUPER + 1-9` | Switch workspace |
| `SUPER + SHIFT + 1-9` | Move window to workspace |
| `SUPER + SHIFT + X` | Power menu (Wlogout) |
| `SUPER + V` | Clipboard history |
| `Print` | Screenshot (region select) |

## Customization

### Personal Overrides

Edit `~/.config/hypr/conf/custom.conf` for Hyprland overrides. This file is never overwritten by the installer or theme switcher.

### Themes

Switch between **modern** and **minimal** themes:

```bash
~/.config/archstoso/themes/themes.sh
```

This changes Waybar, SwayNC, Wlogout, Walker, and Hyprland borders all at once.

### Wallpaper

Change your wallpaper with:

```bash
waypaper
```

Matugen automatically regenerates your color scheme to match the new wallpaper.

### Environment Variables

The default apps are controlled by environment variables in `~/.bashrc`:

```bash
export BROWSER="firefox"
export TERMINAL="kitty"
export EDITOR="nvim"
export FILE_MANAGER="nautilus"
```

Change these to your preferred applications.

## What's Included

| Component | Tool |
|-----------|------|
| Window Manager | Hyprland |
| Status Bar | Waybar (2 themes) |
| Launcher | Walker |
| Terminal | Kitty |
| Notifications | SwayNC |
| Power Menu | Wlogout |
| Color Engine | Matugen |
| Shell Prompt | Oh My Posh (Zen theme) |
| Editor | Neovim |
| Screenshot | Grimblast (grim + slurp) |
| Clipboard | Cliphist |

## File Structure

All configs live under `~/.config/`:

```
~/.config/
  archstoso/       # Core: scripts, settings, themes, wallpapers, colors
  hypr/            # Hyprland config (7 conf files + scripts)
  waybar/          # Waybar config + 2 themes
  walker/          # Walker launcher config
  kitty/           # Kitty terminal config
  matugen/         # Color generation templates
  swaync/          # Notification center
  wlogout/         # Power menu
  bashrc/          # Modular bash configs
  ohmyposh/        # Shell prompt theme
  gtk-3.0/         # GTK3 theme + colors
  gtk-4.0/         # GTK4 theme + colors
  qt6ct/           # Qt6 theme
  btop/            # System monitor config + matugen theme
  fastfetch/       # System info config
  nvim/            # Neovim config
  sidepad/         # Slide-in panel scripts
```

## Troubleshooting

**Blank screen after login** — Check that your GPU drivers are installed. For NVIDIA, you need `nvidia` and `nvidia-utils`. Add `env = LIBVA_DRIVER_NAME,nvidia` to `~/.config/hypr/conf/custom.conf`.

**Waybar not appearing** — Run `~/.config/waybar/launch.sh` manually from a terminal to see errors.

**Colors look wrong** — Run `matugen image /path/to/your/wallpaper.jpg` to regenerate the color scheme.

**Walker not opening** — Verify it's installed: `walker --version`. If missing: `yay -S walker-bin`.

## Restoring Your Previous Setup

If you need to revert, your original configs were saved:

```bash
# Find your backup
ls ~/.config-backup-archstoso-*/

# Restore a specific config (e.g., hypr)
cp -r ~/.config-backup-archstoso-TIMESTAMP/hypr ~/.config/hypr
```

## Uninstalling

There is no uninstall script. To remove ArchStoso:

1. Restore your backed-up configs (see above)
2. Remove ArchStoso-specific directories: `rm -rf ~/.config/archstoso`
3. Remove the environment variable lines from `~/.bashrc`
