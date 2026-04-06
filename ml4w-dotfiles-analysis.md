# ML4W Dotfiles - Comprehensive Analysis

**Project**: ML4W OS - Dotfiles for Hyprland
**Version**: 2.10.1 (Rolling Release)
**Author**: Stephan Raabe
**Repository**: https://github.com/mylinuxforwork/dotfiles

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Hyprland Configuration](#hyprland-configuration)
3. [Waybar](#waybar)
4. [Rofi Application Launcher](#rofi-application-launcher)
5. [Kitty Terminal](#kitty-terminal)
6. [Shell Configurations](#shell-configurations)
7. [Oh My Posh](#oh-my-posh)
8. [Neovim](#neovim)
9. [GTK/Qt Theming](#gtkqt-theming)
10. [Matugen Color System](#matugen-color-system)
11. [Fastfetch](#fastfetch)
12. [Btop](#btop)
13. [NWG Dock](#nwg-dock)
14. [ML4W Custom Apps & Scripts](#ml4w-custom-apps--scripts)
15. [Setup & Installation System](#setup--installation-system)
16. [Development Workflow](#development-workflow)
17. [Miscellaneous Components](#miscellaneous-components)
18. [Architecture & Integration](#architecture--integration)

---

## Project Overview

ML4W (My Linux For Work) Dotfiles is an advanced, full-featured desktop environment configuration for Hyprland on Arch-based Linux distributions. The project stands out for its:

- **Adaptive Material Color Theming**: Uses Matugen to generate cohesive color schemes from wallpapers
- **Modular Architecture**: Highly organized configuration with variation support
- **Custom Applications**: Custom-built tools for settings, calendar, sidebar, and welcome screens
- **Multi-Distribution Support**: Setup scripts for Arch, Fedora, and openSUSE Tumbleweed
- **Professional Installation System**: Uses the `.dotinst` format with the ML4W Dotfiles Installer (available on Flathub)

The configuration follows a philosophy of **user customization without modification** — users are encouraged to create configuration variations rather than editing the default files directly.

---

## Hyprland Configuration

### Main Configuration File
**Location**: `~/.config/hypr/hyprland.conf`

The main config is a **loader file** that sources modular configuration components:

```bash
# Core components loaded in order:
source = ~/.config/hypr/conf/monitor.conf         # Monitor setup
source = ~/.config/hypr/conf/cursor.conf          # Cursor configuration
source = ~/.config/hypr/conf/environment.conf     # Environment variables
source = ~/.config/hypr/conf/keyboard.conf        # Keyboard settings
source = ~/.config/hypr/colors.conf               # Matugen-generated colors
source = ~/.config/hypr/conf/autostart.conf       # Autostart programs
source = ~/.config/hypr/conf/window.conf          # Window settings
source = ~/.config/hypr/conf/decoration.conf      # Decorations & blur
source = ~/.config/hypr/conf/layout.conf          # Layout settings
source = ~/.config/hypr/conf/workspace.conf       # Workspace rules
source = ~/.config/hypr/conf/misc.conf            # Miscellaneous settings
source = ~/.config/hypr/conf/keybinding.conf      # Keybindings
source = ~/.config/hypr/conf/windowrule.conf      # Window rules
source = ~/.config/hypr/conf/animation.conf       # Animation settings
source = ~/.config/hypr/conf/ml4w.conf            # ML4W-specific config
source = ~/.config/hypr/conf/custom.conf          # User custom config
```

### Environment Variables
**Source**: `~/.config/hypr/conf/ml4w.conf`

ML4W sets comprehensive Wayland environment variables:

```bash
# XDG Desktop Portal
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland

# QT Configuration
env = QT_QPA_PLATFORM,wayland;xcb
env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_AUTO_SCREEN_SCALE_FACTOR,1

# GTK/GDK
env = GDK_SCALE,1
env = GDK_BACKEND,wayland,x11,*
env = CLUTTER_BACKEND,wayland

# Mozilla
env = MOZ_ENABLE_WAYLAND,1

# Cursor
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24

# Electron/Chromium
env = OZONE_PLATFORM,wayland
env = ELECTRON_OZONE_PLATFORM_HINT,wayland

# SDL
env = SDL_VIDEODRIVER,wayland
```

**XWayland**: Force zero scaling enabled for proper fractional scaling support.

### Autostart Programs
**Source**: `~/.config/hypr/conf/autostart.conf`

```bash
# ML4W Listeners (GTK theme sync, battery notifications)
exec-once=~/.config/ml4w/listeners.sh --startall

# Polkit Authentication Agent
exec-once=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

# Wallpaper Restoration
exec-once = ~/.config/hypr/scripts/wallpaper-restore.sh

# SwayNC Notification Daemon
exec-once = swaync

# GTK Settings
exec-once = ~/.config/hypr/scripts/gtk.sh

# Hypridle (screen timeout/lock manager)
exec-once = hypridle

# Clipboard History (cliphist)
exec-once = wl-paste --watch cliphist store

# ML4W Autostart Apps
exec-once = ~/.config/ml4w/scripts/ml4w-autostart

# Cleanup Script
exec-once = ~/.config/hypr/scripts/cleanup.sh

# ML4W Settings App Configuration
exec = ~/.config/com.ml4w.hyprlandsettings/hyprctl.sh
```

### Keybindings
**Source**: `~/.config/hypr/conf/keybindings/default.conf`

**Main Modifier**: `SUPER` (Windows key)

#### Application Shortcuts
```bash
SUPER + RETURN        → Terminal
SUPER + B             → Browser
SUPER + E             → File Manager
SUPER CTRL + E        → Emoji Picker
SUPER CTRL + C        → Calculator
SUPER CTRL + RETURN   → Application Launcher
```

#### Window Management
```bash
SUPER + Q             → Kill active window
SUPER SHIFT + Q       → Kill window and all instances
SUPER + F             → Fullscreen
SUPER + M             → Maximize
SUPER + T             → Toggle floating
SUPER + J             → Toggle split
SUPER + G             → Toggle group
SUPER + Arrow Keys    → Move focus
SUPER SHIFT + Arrows  → Resize window
SUPER ALT + Arrows    → Swap windows
ALT + Tab             → Cycle windows
```

#### Workspace Navigation
```bash
SUPER + [1-9,0]       → Switch to workspace 1-10
SUPER SHIFT + [1-9,0] → Move window to workspace
SUPER + Tab           → Next workspace
SUPER SHIFT + Tab     → Previous workspace
SUPER CTRL + [1-9,0]  → Move all windows to workspace
SUPER + Mouse Wheel   → Cycle workspaces
SUPER CTRL + Down     → Open next empty workspace
```

#### System Actions
```bash
SUPER CTRL + R        → Reload Hyprland
SUPER SHIFT + A       → Toggle animations
SUPER + PRINT         → Screenshot (with selection)
SUPER ALT + F         → Instant full screenshot
SUPER ALT + S         → Instant area screenshot
SUPER ALT + A         → Text extraction (OCR)
SUPER CTRL + Q        → Wlogout (power menu)
SUPER SHIFT + W       → Random wallpaper
SUPER CTRL + W        → Wallpaper selector
SUPER ALT + W         → Wallpaper automation
SUPER CTRL + K        → Show keybindings
SUPER SHIFT + B       → Reload Waybar
SUPER CTRL + B        → Toggle Waybar
SUPER + V             → Clipboard manager
SUPER CTRL + T        → Waybar theme switcher
SUPER CTRL + S        → ML4W Settings app
SUPER ALT + G         → Toggle game mode
SUPER CTRL + L        → Lock screen
SUPER SHIFT + H       → Hyprshade toggle
CTRL + Tab            → Window focus menu
CTRL ALT + T          → Theme selector
```

#### Sidepad (Custom Panel)
```bash
SUPER CTRL + Right    → Open Sidepad
SUPER CTRL + Left     → Hide Sidepad
SUPER + S             → Init Sidepad
SUPER SHIFT + S       → Select Sidepad
```

#### Function Keys
```bash
Fn + Brightness Up/Down       → Adjust screen brightness
Fn + Volume Up/Down/Mute      → Audio control
Fn + Media Keys               → Playerctl (play/pause/next/prev)
Fn + Calculator               → Open calculator
Fn + Lock                     → Lock screen
```

### Window Rules
**Source**: `~/.config/hypr/conf/ml4w.conf`

ML4W defines extensive window rules for custom applications:

```bash
# SwayNC (Notification Center) - Blur effects
layerrule2 = blur, swaync-control-center
layerrule2 = ignorezero, swaync-control-center
layerrule2 = ignorealpha 0.5, swaync-control-center

# Pavucontrol - Floating, centered, pinned
windowrule {
    match:class = (.*org.pulseaudio.pavucontrol.*)
    float = true
    center = true
    pin = true
    size = 700 600
}

# ML4W Sidebar - Right-aligned, specific position
windowrule {
    match:class = (com.ml4w.sidebar)
    float = true
    move = monitor_w-window_w-21 76
    pin = true
    size = 400 660
}

# ML4W Settings - Top-centered
windowrule {
    match:class = (com.ml4w.settings)
    float = true
    move = monitor_w*0.5-window_w*0.5 86
    pin = true
    size = 800 600
}

# Picture-in-Picture - Floating and pinned
windowrule {
    match:title = ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$
    float = true
    pin = true
    center = true
}
```

Similar rules exist for: waypaper, blueman-manager, nwg-look, nwg-displays, missioncenter, gnome-calculator, nm-connection-editor, and more.

### Decorations
**Source**: `~/.config/hypr/conf/decorations/default.conf`

**Theme**: \"Rounding All Blur No Shadows\"

```bash
decoration {
    rounding = 10
    active_opacity = 1.0
    inactive_opacity = 0.9
    fullscreen_opacity = 1.0

    blur {
        enabled = true
        size = 4
        passes = 4
        new_optimizations = on
        ignore_opacity = true
        xray = true                # See through tiled windows
    }

    shadow {
        enabled = true
        range = 32
        render_power = 2
        color = rgba(00000050)
    }
}
```

### Animations
**Source**: `~/.config/hypr/conf/animations/default.conf`

**Theme**: \"End-4\" (credit: https://github.com/end-4/dots-hyprland)

Uses custom bezier curves for smooth, professional animations:

```bash
bezier = md3_standard, 0.2, 0, 0, 1
bezier = md3_decel, 0.05, 0.7, 0.1, 1
bezier = md3_accel, 0.3, 0, 0.8, 0.15
bezier = overshot, 0.05, 0.9, 0.1, 1.1
bezier = menu_decel, 0.1, 1, 0, 1
bezier = menu_accel, 0.38, 0.04, 1, 0.07

animation = windows, 1, 3, md3_decel, popin 60%
animation = windowsIn, 1, 3, md3_decel, popin 60%
animation = windowsOut, 1, 3, md3_accel, popin 60%
animation = border, 1, 10, default
animation = fade, 1, 3, md3_decel
animation = layersIn, 1, 3, menu_decel, slide
animation = layersOut, 1, 1.6, menu_accel
animation = workspaces, 1, 7, menu_decel, slide
animation = specialWorkspace, 1, 3, md3_decel, slidevert
```

### Hypridle (Idle Management)
**Location**: `~/.config/hypr/hypridle.conf`

Progressive power management:

```bash
# 8 minutes - Dim screen to 10%
listener {
    timeout = 480
    on-timeout = brightnessctl -s set 10
    on-resume = brightnessctl -r
}

# 10 minutes - Lock session
listener {
    timeout = 600
    on-timeout = loginctl lock-session
}

# 11 minutes - Screen off
listener {
    timeout = 660
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on && brightnessctl -r
}

# 30 minutes - Suspend system
listener {
    timeout = 1800
    on-timeout = systemctl suspend
}
```

### Hyprlock (Lock Screen)
**Location**: `~/.config/hypr/hyprlock.conf`

Uses Matugen-generated colors for Material Design lock screen:

- **Background**: Blurred wallpaper from `~/.cache/ml4w/hyprland-dotfiles/blurred_wallpaper.png`
- **Input Field**: Rounded, primary color with password dots
- **Clock**: Large, right-aligned with primary color
- **User Image**: Circular with primary color gradient border (280px)
- **Username Label**: White text

All elements use shadow effects for depth.

### Colors
**Location**: `~/.config/hypr/colors.conf`

Generated by Matugen from the current wallpaper. Contains Material Design 3 color variables:

```bash
$background, $primary, $secondary, $tertiary
$on_background, $on_primary, $on_secondary, $on_tertiary
$surface, $surface_container, $surface_bright, $surface_dim
$error, $error_container, $on_error, $on_error_container
$outline, $outline_variant, $shadow, $scrim
# ... and many more Material Design 3 color roles
```

---

## Waybar

### Architecture

Waybar uses a **theme system** with multiple pre-built layouts located in `~/.config/waybar/themes/`:

- `ml4w` - Default ML4W theme
- `ml4w-glass` - Glass/transparent effect
- `ml4w-glass-center` - Glass with centered workspaces
- `ml4w-minimal` - Minimal layout
- `ml4w-modern` - Modern design
- `ml4w-transparent` - Transparent background
- `ml4w-transparent-centered` - Transparent with centered elements
- `starter` - Starter template

### Configuration Structure

**Theme Config**: `~/.config/waybar/themes/ml4w/config`

```json
{
    \"layer\": \"top\",
    \"margin-top\": 0,
    \"margin-bottom\": 0,
    \"spacing\": 0,

    // Includes
    \"include\": [
        \"~/.config/ml4w/settings/waybar-quicklinks.json\",
        \"~/.config/waybar/modules.json\"
    ],

    // Module Layout
    \"modules-left\": [
        \"custom/appmenu\",
        \"hyprland/window\",
        \"custom/empty\"
    ],

    \"modules-center\": [
        \"hyprland/workspaces\"
    ],

    \"modules-right\": [
        \"custom/updates\",
        \"pulseaudio\",
        \"bluetooth\",
        \"network\",
        \"battery\",
        \"group/hardware\",
        \"group/tools\",
        \"tray\",
        \"custom/notification\",
        \"custom/exit\",
        \"custom/ml4w-welcome\",
        \"clock\"
    ]
}
```

### Modules
**Source**: `~/.config/waybar/modules.json`

#### Hyprland Integration
```json
\"hyprland/workspaces\": {
    \"on-scroll-up\": \"hyprctl dispatch workspace r-1\",
    \"on-scroll-down\": \"hyprctl dispatch workspace r+1\",
    \"on-click\": \"activate\",
    \"persistent-workspaces\": { \"*\": 5 }
}

\"hyprland/window\": {
    \"max-length\": 60,
    \"rewrite\": {
        \"(.*) - Brave\": \"$1\",
        \"(.*) - Chromium\": \"$1\"
    },
    \"separate-outputs\": true
}
```

#### Custom ML4W Modules

**ML4W Welcome/Sidebar**:
```json
\"custom/ml4w-welcome\": {
    \"on-click\": \"flatpak run com.ml4w.sidebar\",
    \"format\": \" \",
    \"tooltip-format\": \"Open ML4W Sidebar App\"
}
```

**Now Playing** (Media player info):
```json
\"custom/nowplaying\": {
    \"exec\": \"~/.config/ml4w/scripts/ml4w-now-playing\",
    \"format\": \"  {text}\",
    \"return-type\": \"json\",
    \"interval\": 1,
    \"on-click\": \"playerctl play-pause\",
    \"on-click-right\": \"playerctl next\",
    \"on-click-middle\": \"playerctl previous\"
}
```

**Clipboard Manager**:
```json
\"custom/cliphist\": {
    \"format\": \"\",
    \"on-click\": \"~/.config/ml4w/scripts/ml4w-cliphist\",
    \"on-click-right\": \"~/.config/ml4w/scripts/ml4w-cliphist d\",
    \"on-click-middle\": \"~/.config/ml4w/scripts/ml4w-cliphist w\"
}
```

**System Updates**:
```json
\"custom/updates\": {
    \"format\": \"  {}\",
    \"exec\": \"~/.config/ml4w/scripts/ml4w-check-system-updates\",
    \"interval\": 1800,
    \"signal\": 1,
    \"on-click\": \"~/.config/ml4w/settings/installupdates.sh\"
}
```

**Wallpaper Selector**:
```json
\"custom/wallpaper\": {
    \"format\": \"\",
    \"on-click\": \"bash -c waypaper &\",
    \"on-click-right\": \"~/.config/hypr/scripts/wallpaper-effects.sh\"
}
```

**Theme Switcher**:
```json
\"custom/waybarthemes\": {
    \"format\": \"\",
    \"on-click\": \"~/.config/waybar/themeswitcher.sh\"
}
```

**Hypridle Inhibitor**:
```json
\"custom/hypridle\": {
    \"format\": \"\",
    \"return-type\": \"json\",
    \"interval\": 60,
    \"exec\": \"~/.config/hypr/scripts/hypridle.sh status\",
    \"on-click\": \"~/.config/hypr/scripts/hypridle.sh toggle\"
}
```

#### Module Groups

**Hardware Group** (Collapsible):
```json
\"group/hardware\": {
    \"drawer\": {
        \"transition-duration\": 300,
        \"transition-left-to-right\": false
    },
    \"modules\": [\"custom/system\", \"disk\", \"cpu\", \"memory\", \"hyprland/language\"]
}
```

**Tools Group** (Collapsible):
```json
\"group/tools\": {
    \"modules\": [
        \"custom/tools\",
        \"custom/cliphist\",
        \"custom/hypridle\",
        \"custom/hyprshade\",
        \"power-profiles-daemon\"
    ]
}
```

#### Standard Modules

- **Clock**: `{:%H:%M %a}` format, opens ML4W Calendar on click
- **Network**: Shows WiFi strength, connection info
- **Battery**: Icons for different charge levels, warning states
- **Pulseaudio**: Volume control with pavucontrol integration
- **Bluetooth**: Status and device management
- **Backlight**: Screen brightness control
- **Power Profiles**: Performance/balanced/power-saver modes
- **System Tray**: Standard tray icon support

### Styling
**Colors**: `~/.config/waybar/colors.css`

Generated by Matugen, provides CSS color variables:

```css
@define-color background #1a110f;
@define-color primary #ffb59d;
@define-color on_primary #55200c;
@define-color surface #1a110f;
@define-color on_surface #f1dfda;
/* ... full Material Design 3 palette */
```

Each theme has its own `style.css` that imports these colors.

### Scripts

**Launch Script**: `~/.config/waybar/launch.sh`
- Kills existing Waybar instances
- Loads theme from `~/.config/ml4w/settings/waybar-theme.sh`
- Launches Waybar with selected theme config

**Theme Switcher**: `~/.config/waybar/themeswitcher.sh`
- Lists available themes
- Writes selection to `waybar-theme.sh`
- Relaunches Waybar

**Toggle Script**: `~/.config/waybar/toggle.sh`
- Show/hide Waybar

---

## Rofi Application Launcher

### Configuration
**Location**: `~/.config/rofi/config.rasi`

**Font**: Fira Sans 11
**Window Size**: 56em × 35em
**Border**: Dynamic (from `~/.config/ml4w/settings/rofi-border.rasi`)
**Border Radius**: Dynamic (from `~/.config/ml4w/settings/rofi-border-radius.rasi`)

### Modes
```rasi
modi: \"drun,filebrowser,window,run\"
```

- **drun**: Desktop applications (icon: )
- **filebrowser**: File browser (icon: )
- **window**: Window switcher (icon: )
- **run**: Run command (icon: )

### Layout

**Two-column design**:
1. **Left column (imagebox)**: Wallpaper background with input bar and mode switcher
2. **Right column (listbox)**: Application/file list

### Dynamic Theming

Imports multiple dynamic sources:
```rasi
@import \"~/.config/ml4w/settings/rofi-font.rasi\"
@theme \"~/.config/rofi/colors.rasi\"
@import \"~/.cache/ml4w/hyprland-dotfiles/current_wallpaper.rasi\"
@import \"~/.config/ml4w/settings/rofi-border.rasi\"
@import \"~/.config/ml4w/settings/rofi-border-radius.rasi\"
```

### Colors
**Source**: `~/.config/rofi/colors.rasi`

Generated by Matugen with Material Design 3 colors. Uses `@primary`, `@surface`, `@on-surface`, etc.

### Specialized Configs

The project includes specialized Rofi configs for:
- `config-cliphist.rasi` - Clipboard history
- `config-compact.rasi` - Compact layout
- `config-hyprshade.rasi` - Hyprshade shader selection
- `config-ocr-lang.rasi` - OCR language selection
- `config-screenshot.rasi` - Screenshot mode selection
- `config-short.rasi` - Short/minimal layout
- `config-themes.rasi` - Theme selection

### Features

- **Wallpaper Integration**: Uses current wallpaper as background
- **Material Design**: Follows MD3 color principles
- **Icon Support**: Shows application icons
- **Hover Selection**: Supports mouse interaction
- **Adaptive Styling**: Changes with theme/wallpaper

---

## Kitty Terminal

### Configuration
**Location**: `~/.config/kitty/kitty.conf`

### Font Settings
```ini
font_family = JetBrainsMono Nerd Font
font_size = 12
bold_font = auto
italic_font = auto
bold_italic_font = auto
```

### Window Settings
```ini
remember_window_size = no
initial_window_width = 950
initial_window_height = 500
window_padding_width = 10
hide_window_decorations = yes
```

### Visual Effects
```ini
background_opacity = 0.7
dynamic_background_opacity = yes
```

Allows runtime opacity changes with keyboard shortcuts.

### Cursor
```ini
cursor_blink_interval = 0.5
cursor_stop_blinking_after = 1
```

**Cursor Trail Animation**: Enabled via:
```ini
include $HOME/.config/ml4w/settings/kitty-cursor-trail.conf
```

### Color Integration
```ini
include colors-matugen.conf
```

Kitty colors are generated by Matugen from the wallpaper.

### Other Settings
```ini
scrollback_lines = 2000
enable_audio_bell = no
confirm_os_window_close = 0
selection_foreground = none        # Use terminal colors
selection_background = none
```

### Custom Configuration Support
```ini
include $HOME/.config/kitty/custom.conf
```

Users can create `custom.conf` for personal overrides without modifying the main config.

---

## Shell Configurations

### Architecture

ML4W uses a **modular shell configuration system** for Bash, Zsh, and Fish. The main shell RC files (`~/.bashrc`, `~/.zshrc`) are **loaders** that source modular configs.

### Bash
**Main File**: `~/.bashrc`

```bash
# Loads all files from ~/.config/bashrc/
for f in ~/.config/bashrc/*; do
    if [ ! -d $f ]; then
        # Check for custom override
        c=`echo $f | sed -e \"s=.config/bashrc=.config/bashrc/custom=\"`
        [[ -f $c ]] && source $c || source $f
    fi
done

# Load single custom file if exists
if [ -f ~/.bashrc_custom ]; then
    source ~/.bashrc_custom
fi
```

#### Modular Configs
**Location**: `~/.config/bashrc/`

**00-init**:
```bash
export EDITOR=nvim
export PATH=\"/usr/lib/ccache/bin/:$PATH\"
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.local/bin/
```

**10-aliases**:
```bash
# Navigation
alias ..='cd ..'
alias c='clear'

# Listing (uses eza with icons)
alias ls='eza -a --icons=always'
alias ll='eza -al --icons=always'
alias lt='eza -a --tree --level=1 --icons=always'

# System fetch
alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'

# System
alias shutdown='systemctl poweroff'
alias v='$EDITOR'
alias vim='$EDITOR'
alias wifi='nmtui'
alias lock='hyprlock'

# ML4W Scripts
alias arch-cleanup='~/.config/ml4w/scripts/arch/cleanup.sh'
alias apps='~/.config/ml4w/bin/ml4w-apps.sh'
alias screenshot='~/.config/ml4w/bin/ml4w-screenshot.sh'
alias updates='~/.config/ml4w/scripts/ml4w-install-system-updates'
alias wallpaper='~/.config/ml4w/bin/ml4w-wallpaper.sh'

# ML4W Flatpak Apps
alias ml4w='flatpak run com.ml4w.welcome'
alias ml4w-settings='flatpak run com.ml4w.settings'
alias ml4w-calendar='flatpak run com.ml4w.calendar'
alias ml4w-hyprland='flatpak run com.ml4w.hyprlandsettings'
alias ml4w-sidebar='flatpak run com.ml4w.sidebar'

# Git shortcuts
alias gs=\"git status\"
alias ga=\"git add\"
alias gc=\"git commit -m\"
alias gp=\"git push\"
alias gpl=\"git pull\"
alias gst=\"git stash\"
```

**20-customization**:
```bash
# Oh My Posh prompt
eval \"$(oh-my-posh init bash --config $HOME/.config/ohmyposh/zen.toml)\"
```

**30-autostart**:
- Additional autostart logic (if needed)

### Zsh
**Main File**: `~/.zshrc`

Identical loader structure to Bash, sources from `~/.config/zshrc/` with the same modular files.

### Fish
**Main File**: `~/.config/fish/config.fish`

Currently empty, configuration would be in `~/.config/fish/conf.d/`.

### Customization System

Users have **three ways** to customize without editing defaults:

1. **Create custom folder**: `~/.config/bashrc/custom/` with file overrides
2. **Single custom file**: `~/.bashrc_custom` or `~/.zshrc_custom`
3. **Edit modular files**: Directly edit files in `~/.config/bashrc/`

The custom folder approach is recommended for version control safety.

---

## Oh My Posh

### Configuration
**Location**: `~/.config/ohmyposh/zen.toml`

**Theme**: Zen (minimal, modern prompt)

### Structure

```toml
console_title_template = '{{ .Shell }} in {{ .Folder }}'
version = 3
final_space = true
```

### Prompt Segments

**Left Prompt** (Line 1):
- **Path**: Full path in blue
- **Git**: Branch name with status indicators (*, ⇣, ⇡)

**Right Prompt**:
- **Execution Time**: Shows command duration (yellow) if >5 seconds

**Prompt Symbol** (Line 2):
- `❯` in magenta (success) or red (error)

### Transient Prompt
```toml
[transient_prompt]
  template = '❯ '
  foreground_templates = [
    '{{if gt .Code 0}}red{{end}}',
    '{{if eq .Code 0}}magenta{{end}}'
  ]
```

After command execution, replaces full prompt with minimal `❯`.

### Color Integration

ML4W generates `~/.config/ohmyposh/colors.json` from wallpaper via Matugen, which can be merged into theme files using jq (see Matugen section).

### Alternative Theme

Commented out in config:
```bash
# eval \"$(oh-my-posh init bash --config $HOME/.config/ohmyposh/EDM115-newline.omp.json)\"
```

EDM115-newline theme available but not active by default.

---

## Neovim

### Configuration
**Location**: `~/.config/nvim/init.vim`

**Philosophy**: Minimal, performant, transparent background configuration.

### Settings
```vim
set nocompatible            \" No vi compatibility
set showmatch               \" Show matching brackets
set ignorecase              \" Case insensitive search
set mouse=v                 \" Middle-click paste
set hlsearch                \" Highlight search results
set incsearch               \" Incremental search
set tabstop=4               \" Tab width
set softtabstop=4
set expandtab               \" Tabs to spaces
set shiftwidth=4            \" Auto-indent width
set autoindent
set number                  \" Line numbers
set wildmode=longest,list   \" Bash-like tab completion
set mouse=a                 \" Full mouse support
set clipboard=unnamedplus   \" System clipboard
set ttyfast                 \" Fast scrolling
```

### Transparency

Nvim background is forced transparent to match terminal:

```vim
hi NonText ctermbg=none guibg=NONE
hi Normal guibg=NONE ctermbg=NONE
hi NormalNC guibg=NONE ctermbg=NONE
hi SignColumn ctermbg=NONE ctermfg=NONE guibg=NONE
hi Pmenu ctermbg=NONE ctermfg=NONE guibg=NONE
hi FloatBorder ctermbg=NONE ctermfg=NONE guibg=NONE
hi NormalFloat ctermbg=NONE ctermfg=NONE guibg=NONE
hi TabLine ctermbg=None ctermfg=None guibg=None
```

### Plugins

The default config is **plugin-free**. Users are expected to add their own plugin manager (vim-plug, packer, lazy.nvim) and plugins.

### Customization

Create `~/.config/nvim/custom.vim` or use Neovim's standard plugin/config structure.

---

## GTK/Qt Theming

### GTK 3
**Location**: `~/.config/gtk-3.0/settings.ini`

```ini
[Settings]
gtk-theme-name=Adwaita
gtk-icon-theme-name=Colloid-Dark
gtk-font-name=Fira Sans Semi-Bold 11
gtk-cursor-theme-name=ArcStarry-cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
```

**Dark Theme**: Enabled globally
**Font Rendering**: Antialiasing with slight hinting (hintslight)

### GTK 4
**Location**: `~/.config/gtk-4.0/settings.ini`

Same configuration as GTK 3.

### GTK 2
**Location**: `~/.gtkrc-2.0`

```ini
include \"/home/raabe/.gtkrc-2.0.mine\"
gtk-theme-name=\"Adwaita\"
gtk-icon-theme-name=\"Colloid-Dark\"
gtk-font-name=\"Fira Sans Semi-Bold 11\"
gtk-cursor-theme-name=\"Bibata-Modern-Ice\"
```

**Note**: File mentions it's managed by `nwg-look` (GTK theme switcher).

### Material Color Integration

Matugen generates `~/.config/gtk-3.0/colors.css` and `~/.config/gtk-4.0/colors.css` with Material Design colors:

```css
@define-color background #1a110f;
@define-color primary #ffb59d;
@define-color on_primary #55200c;
/* ... */
```

These can be used in custom GTK CSS.

### Qt
**Location**: `~/.config/qt6ct/qt6ct.conf`

```ini
[Appearance]
color_scheme_path=/usr/share/qt6ct/colors/darker.conf
custom_palette=true
icon_theme=breeze-dark
style=Breeze

[Interface]
activate_item_on_single_click=1
dialog_buttons_have_icons=1
menus_have_icons=true
show_shortcuts_in_context_menus=true
```

**QT Platform Theme**: Set via environment variable in Hyprland:
```bash
env = QT_QPA_PLATFORMTHEME,qt6ct
```

### Theme Management

Users can change themes with:
- **nwg-look**: GTK theme GUI
- **qt6ct**: Qt configuration tool
- **ML4W Settings**: Integrated theme switcher

All controlled via `~/.config/ml4w/settings/` scripts.

---

## Matugen Color System

### Overview

**Matugen** is the heart of ML4W's theming system. It generates **Material Design 3** color palettes from wallpapers and applies them across the entire desktop.

### Configuration
**Location**: `~/.config/matugen/config.toml`

### Template System

Matugen uses **templates** to generate config files for every component:

```toml
[templates.kitty]
input_path = '~/.config/matugen/templates/kitty-colors.conf'
output_path = '~/.config/kitty/colors-matugen.conf'
post_hook = 'pkill -SIGUSR1 kitty'

[templates.hyprland]
input_path = '~/.config/matugen/templates/hyprland-colors.conf'
output_path = '~/.config/hypr/colors.conf'
post_hook = 'hyprctl reload'

[templates.waybar]
input_path = '~/.config/matugen/templates/colors.css'
output_path = '~/.config/waybar/colors.css'

[templates.rofi]
input_path = '~/.config/matugen/templates/rofi-colors.rasi'
output_path = '~/.config/rofi/colors.rasi'

[templates.btop]
input_path = '~/.config/matugen/templates/btop.theme'
output_path = '~/.config/btop/themes/matugen.theme'
post_hook = 'pkill -USR2 btop'

[templates.gtk3]
input_path = '~/.config/matugen/templates/gtk-colors.css'
output_path = '~/.config/gtk-3.0/colors.css'

[templates.gtk4]
input_path = '~/.config/matugen/templates/gtk-colors.css'
output_path = '~/.config/gtk-4.0/colors.css'

[templates.swaync]
input_path = '~/.config/matugen/templates/colors.css'
output_path = '~/.config/swaync/colors.css'

[templates.wlogout]
input_path = '~/.config/matugen/templates/colors.css'
output_path = '~/.config/wlogout/colors.css'

[templates.walker]
input_path = '~/.config/matugen/templates/colors.css'
output_path = '~/.config/walker/colors.css'

[templates.nwgdock]
input_path = '~/.config/matugen/templates/colors.css'
output_path = '~/.config/nwg-dock-hyprland/colors.css'

[templates.ohmyposh]
input_path = '~/.config/matugen/templates/ohmyposh-colors.json'
output_path = '~/.config/ohmyposh/colors.json'
post_hook = \"jq --slurpfile palette ~/.config/ohmyposh/colors.json '. + $palette[0]' ~/.config/ohmyposh/EDM115-newline.omp.json > /tmp/new_theme.json && mv /tmp/new_theme.json ~/.config/ohmyposh/EDM115-newline.omp.json\"

[templates.pywalfox]
input_path = '~/.config/matugen/templates/pywalfox-colors.json'
output_path = '~/.cache/wal/colors.json'
```

### ML4W Color Extraction

Special templates extract specific colors for scripts:

```toml
[templates.primary]
input_path = '~/.config/matugen/templates/primary'
output_path = '~/.config/ml4w/colors/primary'

[templates.secondary]
input_path = '~/.config/matugen/templates/secondary'
output_path = '~/.config/ml4w/colors/secondary'

[templates.on_surface]
input_path = '~/.config/matugen/templates/onsurface'
output_path = '~/.config/ml4w/colors/onsurface'

[templates.on_primary]
input_path = '~/.config/matugen/templates/onprimary'
output_path = '~/.config/ml4w/colors/onprimary'
```

These individual color files are used by ML4W scripts for dynamic styling.

### Post Hooks

**Purpose**: Reload applications after color generation

- **Kitty**: `pkill -SIGUSR1 kitty` (reload config signal)
- **Btop**: `pkill -USR2 btop` (reload theme signal)
- **Hyprland**: `hyprctl reload` (full config reload)
- **Oh My Posh**: `jq` command to merge colors into theme

### Color Workflow

1. User selects wallpaper (via waypaper or scripts)
2. Wallpaper script calls `matugen image <wallpaper_path>`
3. Matugen analyzes wallpaper, generates MD3 palette
4. All templates are rendered with new colors
5. Post-hooks reload affected applications
6. Desktop instantly adapts to new color scheme

### Material Design 3 Colors

Generated colors follow Google's Material Design 3 spec:

**Primary Colors**: Main brand color from wallpaper
**Secondary Colors**: Complementary accent
**Tertiary Colors**: Additional accent
**Surface Colors**: Backgrounds with elevation levels
**Error Colors**: Error states
**Outline Colors**: Borders and dividers

Each color has **on-color** variants for proper contrast (e.g., `on_primary` for text on `primary` background).

### Integration Examples

**Hyprland** (`colors.conf`):
```bash
$primary = rgba(ffb59dff)
$on_surface = rgba(f1dfdaff)
```

**Waybar** (`colors.css`):
```css
@define-color primary #ffb59d;
@define-color surface #1a110f;
```

**Rofi** (`colors.rasi`):
```rasi
* {
    primary: #ffb59dff;
    surface: #1a110fff;
}
```

---

## Fastfetch

### Configuration
**Location**: `~/.config/fastfetch/config.jsonc`

**Inspiration**: Catnap theme

### Logo
```json
\"logo\": {
    \"source\": \"~/.config/ml4w/assets/ml4w.png\",
    \"type\": \"auto\",
    \"width\": 16,
    \"padding\": {
        \"top\": 1,
        \"right\": 4,
        \"left\": 3
    }
}
```

Uses the ML4W logo image with kitty image protocol support.

### Display Settings
```json
\"display\": {
    \"separator\": \" \"
}
```

Clean, minimal separator.

### Modules

Displays system information in a bordered box format:

```
╭───────────╮
│  user     │  Username
│ 󰇅 hname   │  Hostname
│ 󱦟 os age  │  System age in days (custom command)
│ 󰅐 uptime  │  System uptime
│  distro   │  Distribution with icon
│  kernel   │  Kernel version
│  wm       │  Window manager (Hyprland)
│ 󰇄 desktop  │  Desktop environment
│  term     │  Terminal emulator
│  shell    │  Shell (bash/zsh/fish)
│ 󰍛 cpu     │  CPU model
│ 󰉉 disk    │  Disk usage (/)
│  memory   │  RAM usage
├───────────┤
│  colors   │  Color palette preview
╰───────────╯
```

### Custom Module: OS Age

```json
{
  \"type\": \"command\",
  \"key\": \"│ {#33}󱦟 os age  {#keys}│\",
  \"text\": \"printf \\\"\\\\e[0m%s days\\\\e[0m\\\" \\\"$(( ($(date +%s) - $(stat -c %W /)) / 86400 ))\\\"\"
}
```

Calculates days since root filesystem creation.

### Color Coding

Uses colored icons for visual organization:
- `{#31}` - Red
- `{#32}` - Green
- `{#33}` - Yellow
- `{#34}` - Blue
- `{#35}` - Magenta
- `{#36}` - Cyan

---

## Btop

### Configuration
**Location**: `~/.config/btop/btop.conf`

**Version**: 1.4.6

### Theme
```ini
color_theme = \"matugen\"
theme_background = true
truecolor = true
```

Uses Matugen-generated theme at `~/.config/btop/themes/matugen.theme`.

### Display Settings
```ini
rounded_corners = true
terminal_sync = true
graph_symbol = \"braille\"        # High-resolution graphs
```

**Braille Graphs**: Uses Unicode braille characters for smooth, detailed graphs.

### Presets
```ini
presets = \"cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty\"
```

Three preset layouts for different views.

### Boxes
```ini
shown_boxes = \"cpu mem net proc\"
```

Shows CPU, memory, network, and process information.

### Process Settings
```ini
proc_sorting = \"cpu lazy\"       # Top process over time
proc_reversed = false
proc_tree = false               # List view (not tree)
proc_colors = true
proc_gradient = true
proc_per_core = false
proc_mem_bytes = true
proc_cpu_graphs = true          # Individual process graphs
```

### Update Interval
```ini
update_ms = 2000                # 2 seconds
```

Balanced between responsiveness and CPU usage.

### Integration

Matugen automatically reloads btop when colors change:
```toml
post_hook = 'pkill -USR2 btop'
```

---

## NWG Dock

### Location
`~/.config/nwg-dock-hyprland/`

### Structure

- `colors.css` - Matugen-generated colors
- `launch.sh` - Launch script
- `themes/` - Theme presets

### Theme System

Themes are selected via:
```bash
echo \"modern\" > $HOME/.config/ml4w/settings/dock-theme
```

Available in `~/.config/nwg-dock-hyprland/themes/`.

### Launch Script
**Location**: `~/.config/nwg-dock-hyprland/launch.sh`

- Kills existing dock instances
- Reads theme from `~/.config/ml4w/settings/dock-theme`
- Launches nwg-dock-hyprland with selected theme

### Integration

Part of the ML4W theme system. Themes (modern, glass, transparent) set the dock theme automatically:

```bash
# From theme.sh
echo \"modern\" > $HOME/.config/ml4w/settings/dock-theme
$HOME/.config/nwg-dock-hyprland/launch.sh &
```

### Color Synchronization

Matugen generates dock colors:
```toml
[templates.nwgdock]
input_path = '~/.config/matugen/templates/colors.css'
output_path = '~/.config/nwg-dock-hyprland/colors.css'
```

---

## ML4W Custom Apps & Scripts

### Overview

ML4W includes **custom applications** (Flatpaks) and **helper scripts** that tie the entire system together.

### Custom Applications (Flatpak)

**Available Apps**:
- `com.ml4w.welcome` - Welcome/onboarding app
- `com.ml4w.settings` - ML4W Settings manager
- `com.ml4w.calendar` - Calendar widget
- `com.ml4w.sidebar` - Information sidebar
- `com.ml4w.hyprlandsettings` - Hyprland configuration GUI

**Access**:
```bash
flatpak run com.ml4w.settings
# Or via aliases:
ml4w-settings
```

Integrated into Waybar and keybindings.

### Directory Structure
**Location**: `~/.config/ml4w/`

```
ml4w/
├── assets/          # Icons, images, logos
├── bin/             # Binary wrapper scripts
├── colors/          # Extracted colors (primary, secondary, etc.)
├── library.sh       # Shared functions
├── listeners/       # Background listener scripts
├── listeners.sh     # Listener manager
├── scripts/         # Utility scripts
├── settings/        # App/setting selector scripts
├── themes/          # Desktop theme presets
├── tpl/             # Templates
├── version.json     # Version information
└── wallpapers/      # Default wallpapers
```

### Listener System
**Script**: `~/.config/ml4w/listeners.sh`

**Purpose**: Centralized manager for background listener scripts.

**Registered Listeners**:
```bash
LISTENERS[\"gtk-theme-switcher\"]=\"$HOME/.config/ml4w/listeners/gtk-theme-switcher.sh\"
LISTENERS[\"low-bat-notification\"]=\"$HOME/.config/ml4w/listeners/low-bat-notification.sh\"
```

**Commands**:
```bash
~/.config/ml4w/listeners.sh --startall     # Start all listeners
~/.config/ml4w/listeners.sh --stopall      # Stop all listeners
~/.config/ml4w/listeners.sh --start <name> # Start specific listener
~/.config/ml4w/listeners.sh --stop <name>  # Stop specific listener
```

**Autostart**: Called from Hyprland's autostart:
```bash
exec-once=~/.config/ml4w/listeners.sh --startall
```

**Functionality**:
- **gtk-theme-switcher**: Monitors GTK theme changes, synchronizes across GTK 2/3/4
- **low-bat-notification**: Sends notifications at low battery levels

### Key Scripts

**Location**: `~/.config/ml4w/scripts/`

#### System Management
- `ml4w-autostart` - Handles ML4W-specific autostart tasks
- `ml4w-check-dotfiles-update` - Checks for dotfiles updates
- `ml4w-check-system-updates` - Counts available system updates (for Waybar)
- `ml4w-install-system-updates` - Updates system packages
- `ml4w-install-sddm` - Installs/configures SDDM theme
- `arch/cleanup.sh` - Arch Linux cleanup (orphan packages, cache)

#### UI Components
- `ml4w-cliphist` - Clipboard history manager (Rofi frontend for cliphist)
- `ml4w-wlogout` - Wlogout launcher
- `ml4w-sidepad` - Sidepad panel manager
- `ml4w-now-playing` - Media player status (JSON for Waybar)

#### Utilities
- `ml4w-ascii-header` - Prints ML4W ASCII art
- `ml4w-dotfiles-id` - Shows dotfiles identifier
- `ml4w-network` - Network status
- `ml4w-notification-handler` - Custom notification processor
- `ml4w-toggle-nmapplet` - Toggle nm-applet
- `ml4w-toggle-theme` - Theme switcher
- `ml4w-change-shell` - Shell switcher (bash/zsh/fish)

### Settings Scripts

**Location**: `~/.config/ml4w/settings/`

These scripts **select and launch** user-preferred applications:

#### Application Selectors
- `browser.sh` - Default browser
- `calculator.sh` - Calculator app
- `editor.sh` - Text editor
- `email.sh` - Email client
- `emojipicker.sh` - Emoji picker
- `filemanager.sh` / `filemanager` - File manager
- `terminal.sh` - Terminal emulator
- `launcher` - Application launcher (rofi/walker)

**Example** (`browser.sh`):
```bash
#!/bin/bash
firefox
```

Users modify these to change default apps without editing keybindings.

#### System Tools
- `networkmanager.sh` - NetworkManager GUI
- `bluetooth.sh` - Bluetooth manager
- `installupdates.sh` - System updater
- `printer-drivers.sh` - Printer driver installer
- `system-monitor.sh` - Task manager
- `hyprshade.sh` - Hyprshade shader manager
- `hyprpicker.sh` - Hyprpicker color picker

#### Theme Configuration Files
- `rofi-border.rasi` - Rofi border width
- `rofi-border-radius.rasi` - Rofi corner radius
- `rofi-font.rasi` - Rofi font
- `kitty-cursor-trail.conf` - Kitty cursor animation
- `dock-border.css` - Dock border styling
- `dock-theme` - Current dock theme name
- `launcher` - Current launcher (rofi/walker)
- `walker-theme` - Walker theme name
- `waybar-theme.sh` - Waybar theme path

### Theme System

**Location**: `~/.config/ml4w/themes/`

**Available Themes**:
- `glass` - Glass transparency effect
- `glass-walker` - Glass with Walker launcher
- `modern` - Modern design
- `modern-walker` - Modern with Walker
- `transparent` - Transparent elements

Each theme contains a `theme.sh` script that:

1. **Sets Waybar theme**:
```bash
echo \"/ml4w-modern;/ml4w-modern/default\" > $HOME/.config/ml4w/settings/waybar-theme.sh
$HOME/.config/waybar/launch.sh &
```

2. **Sets dock theme**:
```bash
echo \"modern\" > $HOME/.config/ml4w/settings/dock-theme
$HOME/.config/nwg-dock-hyprland/launch.sh &
```

3. **Sets SwayNC style**:
```bash
echo '@import \"themes/modern/style.css\";' > $HOME/.config/swaync/style.css
swaync-client -rs
```

4. **Sets wlogout style**:
```bash
echo '@import \"themes/modern/style.css\";' > $HOME/.config/wlogout/style.css
```

5. **Sets launcher**:
```bash
echo 'rofi' > $HOME/.config/ml4w/settings/launcher
```

6. **Sets window borders**:
```bash
echo 'source = ~/.config/hypr/conf/windows/border-2.conf' > $HOME/.config/hypr/conf/window.conf
```

7. **Sets Rofi styling**:
```bash
echo '* { border-width: 2px; }' > $HOME/.config/ml4w/settings/rofi-border.rasi
```

**Theme Switcher**: `~/.config/ml4w/themes/themes.sh`
- Lists available themes
- Launches with Rofi or Walker
- Executes selected theme's `theme.sh`

---

## Setup & Installation System

### Overview

ML4W uses a sophisticated installation system based on the `.dotinst` file format and supports multiple distributions.

### .dotinst File Format
**File**: `hyprland-dotfiles.dotinst`

JSON metadata describing the dotfiles package:

```json
{
    \"name\": \"ML4W OS - Dotfiles for Hyprland (ROLLING RELEASE)\",
    \"id\": \"com.ml4w.dotfiles\",
    \"description\": \"Advanced configuration for Hyprland\",
    \"version\": \"2.10.1\",
    \"author\": \"Stephan Raabe\",
    \"homepage\": \"https://ml4w.com/os/\",
    \"dependencies\": \"https://ml4w.com/os/getting-started/dependencies\",
    \"source\": \"https://github.com/mylinuxforwork/dotfiles.git\",
    \"subfolder\": \"dotfiles\",
    \"setupscript\": \"setup/setup.sh\"
}
```

### Installation Methods

#### 1. ML4W Dotfiles Installer (Recommended)
- **Flatpak App**: Available on Flathub
- **GUI Interface**: Visual installation wizard
- **URL-based**: Paste `.dotinst` URL to install
- **Automatic**: Handles dependencies, backups, restoration

**Stable Release**:
```
https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/hyprland-dotfiles-stable.dotinst
```

**Rolling Release**:
```
https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/hyprland-dotfiles.dotinst
```

#### 2. Live ISO
- **ML4W OS ISO**: Bootable Arch-based live environment
- **Pre-configured**: Full ML4W experience out of the box
- **Installable**: Can install to disk with `sudo install-ml4w-os`

#### 3. Setup Scripts (Manual)
- **Arch**: `setup/setup-arch.sh`
- **Fedora**: `setup/setup-fedora.sh`
- **OpenSuse**: `setup/setup-opensuse.sh`

### Setup Architecture

**Main Script**: `setup/setup.sh`

**Auto-detection**:
```bash
if [[ $(_checkCommandExists \"pacman\") == 0 ]]; then
    $SCRIPT_DIR/setup-arch.sh
elif [[ $(_checkCommandExists \"dnf\") == 0 ]]; then
    $SCRIPT_DIR/setup-fedora.sh
elif [[ $(_checkCommandExists \"zypper\") == 0 ]]; then
    $SCRIPT_DIR/setup-opensuse.sh
else
    # Manual dependency list
    $SCRIPT_DIR/dependencies.sh
fi
```

**Library Functions**: `setup/_lib.sh`

```bash
_checkCommandExists()  # Check if command is available
_writeHeader()         # Display setup banner
_finishMessage()       # Show completion message
```

Uses **gum** for interactive prompts and UI.

### Package Management

**Location**: `setup/packages/`

Separate package lists for different components:
- `eza/` - Eza file lister packages
- `matugen/` - Matugen color generator packages

### Restoration System

The `.dotinst` file defines which configs to backup/restore:

```json
\"restore\": [
    {
        \"title\": \"ML4W Settings\",
        \"source\": \".config/ml4w/settings\",
        \"value\": true
    },
    {
        \"title\": \"Keyboard\",
        \"source\": \".config/hypr/conf/keyboard.conf\",
        \"value\": true
    },
    {
        \"title\": \"Monitor\",
        \"source\": \".config/hypr/conf/monitor.conf\",
        \"value\": true
    }
    // ... more items
]
```

**value**: Default restore behavior (true = restore by default)

### First-Time Settings

Configuration wizard options defined in `.dotinst`:

```json
\"settings\": [
    {
        \"type\": \"text\",
        \"mode\": \"replacesingleline\",
        \"title\": \"Keyboard Layout\",
        \"file\": \".config/hypr/conf/keyboard.conf\",
        \"search\": \"kb_layout\",
        \"value\": \"us\",
        \"template\": \"    kb_layout = [VALUE]\"
    },
    {
        \"type\": \"text\",
        \"mode\": \"overwritefile\",
        \"title\": \"Default Terminal\",
        \"file\": \".config/ml4w/settings/terminal.sh\",
        \"value\": \"kitty\",
        \"template\": \"\"
    }
    // ... more settings
]
```

**Modes**:
- `replacesingleline` - Replace specific line in file
- `overwritefile` - Replace entire file content

---

## Development Workflow

### Sync Daemon
**Script**: `dev/sync.sh`

**Purpose**: Development synchronization between working directory and Git repository.

**How it works**:

1. **Reads .dotinst**: Determines source and target directories
2. **Monitors changes**: Uses `inotifywait` to watch for file modifications
3. **Syncs with rsync**: Automatically syncs changes to Git repo
4. **Respects protections**: Excludes files listed in `dev/protected.txt`

**Usage**:
```bash
./dev/sync.sh           # Normal mode
./dev/sync.sh --dry-run # Test mode (no changes)
```

**Configuration**:
```bash
SOURCE_DIR=\"$HOME/.config/hypr\"  # Working config
TARGET_DIR=\"$HOME/.mydotfiles/com.ml4w.dotfiles\"  # Git repo
EVENTS=\"modify,create,delete,move\"
EXCLUDE_FILE=\"dev/protected.txt\"
```

**Protected Files**: `dev/protected.txt`
```
keyboard.conf
custom.conf
monitors.conf
waypaper
```

These files contain user-specific settings and should not be synced to the repository.

**Sync Process**:
1. Detects file change in `SOURCE_DIR`
2. Waits 1 second (debounce)
3. Runs rsync with exclusions
4. Continues monitoring

**Advantages**:
- **Real-time**: Changes immediately reflected in repo
- **Safe**: Protected files never overwritten
- **Efficient**: Only syncs changed files
- **Testable**: Dry-run mode for safety

### Release Process

1. **Development**: Edit configs in `~/.config/`
2. **Sync**: `dev/sync.sh` copies to Git repo
3. **Test**: Verify in `.mydotfiles/` directory
4. **Commit**: Standard Git workflow
5. **Tag Release**: Create version tag
6. **Update .dotinst**: Bump version number
7. **Push**: Push to GitHub

### Version Management

**Version File**: `~/.config/ml4w/version.json`

```json
{
    \"version\": \"2.10.1\",
    \"type\": \"rolling\"
}
```

Scripts can check version for compatibility:
```bash
version=$(jq -r '.version' ~/.config/ml4w/version.json)
```

### Stable vs Rolling

**Two .dotinst files**:
- `hyprland-dotfiles.dotinst` - Rolling release (latest commits)
- `hyprland-dotfiles-stable.dotinst` - Stable release (tagged versions)

Users choose installation channel based on preference for stability vs features.

---

## Miscellaneous Components

### SwayNC (Notification Daemon)
**Location**: `~/.config/swaync/`

**Config**: `config.json`

**Features**:
- Control center: 360×700px, top-right positioning
- Notification window: 360px wide
- Timeout: 4s normal, 2s low priority, 6s critical
- Widgets: DND toggle, buttons grid, backlight, volume, MPRIS
- Wi-Fi/Bluetooth toggle buttons in control center

**Styling**:
- Uses Matugen colors
- Theme-based styles (modern, glass, transparent)
- Blur effects via Hyprland layer rules

**Integration**:
- Waybar module shows notification status
- Keybindings for show/hide, DND toggle
- Custom notification scripts

### Wlogout (Power Menu)
**Location**: `~/.config/wlogout/`

**Actions**: Logout, lock, suspend, hibernate, reboot, shutdown

**Styling**:
- Matugen color integration
- Theme-specific styles
- Icon-based buttons

**Launch**:
```bash
~/.config/ml4w/scripts/ml4w-wlogout
```

### Walker (Alternative Launcher)
**Location**: `~/.config/walker/`

Modern, feature-rich application launcher as alternative to Rofi.

**Integration**:
- Theme support (modern-walker, glass-walker)
- Matugen colors
- Selectable via ML4W themes

**Features**:
- Application search
- File browser
- Window switcher
- Calculator
- Clipboard manager

### Waypaper (Wallpaper Manager)
**Integration**:
- Wallpaper selection GUI
- Saves selection to `~/.config/waypaper/`
- Triggers Matugen color generation
- Blurs wallpaper for lock screen
- Creates square version for hyprlock

**Scripts**:
- `~/.config/hypr/scripts/wallpaper-restore.sh` - Restore last wallpaper
- `~/.config/hypr/scripts/wallpaper-automation.sh` - Auto wallpaper rotation
- `~/.config/hypr/scripts/wallpaper-effects.sh` - Effect selection
- `~/.config/hypr/scripts/wallpaper-cache.sh` - Generate cached versions

### Sidepad
**Custom Component**: `~/.config/sidepad/`

Retractable side panel for quick information/tools.

**Control**:
```bash
~/.config/ml4w/scripts/ml4w-sidepad
~/.config/ml4w/scripts/ml4w-sidepad --hide
~/.config/ml4w/scripts/ml4w-sidepad --init
~/.config/ml4w/scripts/ml4w-sidepad --select
```

**Keybindings**:
- `SUPER CTRL + Right` - Show
- `SUPER CTRL + Left` - Hide
- `SUPER + S` - Init
- `SUPER SHIFT + S` - Select

### Xresources
**Location**: `~/.Xresources`

X11 resource configuration for backward compatibility with X11 apps running under XWayland.

### Browser Flags

**Chromium**: `~/.config/chromium-flags.conf`
```
--ozone-platform=wayland
--ozone-platform-hint=wayland
--enable-features=TouchpadOverscrollHistoryNavigation
```

**Edge**: `~/.config/edge-flags.conf`
```
--ozone-platform-hint=auto
--enable-features=UseOzonePlatform
--ozone-platform=wayland
```

Forces Wayland mode for better performance and native Wayland features.

### Hyprland Scripts

**Location**: `~/.config/hypr/scripts/`

- `cleanup.sh` - Cleans temporary files on startup
- `focus.sh` - Window focus selector
- `gamemode.sh` - Toggles game mode optimizations
- `gtk.sh` - Applies GTK settings
- `hypridle.sh` - Hypridle control
- `hyprshade.sh` - Screen shader toggle
- `keybindings.sh` - Keybinding viewer (Rofi)
- `launcher.sh` - Application launcher
- `loadconfig.sh` - Reload Hyprland config
- `moveTo.sh` - Move all windows to workspace
- `power.sh` - Power management actions
- `screenshot.sh` - Screenshot with selection/full/area modes
- `text-extractor.sh` - OCR text extraction
- `toggle-animations.sh` - Enable/disable animations
- `wallpaper-automation.sh` - Auto wallpaper changer

---

## Architecture & Integration

### Component Relationships

```
Wallpaper Selection (waypaper)
    ↓
Matugen Color Generation
    ↓
┌───────────────────────────────────────────────────┐
│ Color Templates Generated for All Components     │
├───────────────────────────────────────────────────┤
│ • Hyprland (colors.conf)                         │
│ • Waybar (colors.css)                            │
│ • Rofi (colors.rasi)                             │
│ • Kitty (colors-matugen.conf)                    │
│ • Btop (matugen.theme)                           │
│ • GTK 3/4 (colors.css)                           │
│ • SwayNC (colors.css)                            │
│ • Wlogout (colors.css)                           │
│ • Walker (colors.css)                            │
│ • NWG Dock (colors.css)                          │
│ • Oh My Posh (colors.json)                       │
└───────────────────────────────────────────────────┘
    ↓
Post-Hooks Reload Applications
    ↓
Unified Color Scheme Across Desktop
```

### Configuration Hierarchy

**Level 1: Core Defaults**
- Located in `dotfiles/.config/`
- Provided by ML4W project
- Should not be modified directly

**Level 2: Variations**
- Located in component-specific variation folders
- Example: `~/.config/hypr/conf/animations/`, `~/.config/hypr/conf/decorations/`
- User selects via symlinks or includes

**Level 3: Custom Overrides**
- `~/.config/hypr/conf/custom.conf`
- `~/.config/bashrc/custom/`
- `~/.bashrc_custom`, `~/.zshrc_custom`
- `~/.config/kitty/custom.conf`
- User-specific modifications

**Level 4: Runtime Settings**
- `~/.config/ml4w/settings/` scripts
- Dynamically selected apps
- Theme choices
- Generated by ML4W applications

### Data Flow

**User Action** → **Script** → **Setting File** → **Config Reload** → **Visual Change**

Example: Changing terminal
1. User: Opens ML4W Settings → Terminal Selector
2. Settings App: Writes `kitty` to `~/.config/ml4w/settings/terminal.sh`
3. Keybinding: Sources `terminal.sh`, launches Kitty
4. Result: Terminal opens

Example: Changing wallpaper
1. User: `SUPER + CTRL + W` → Opens Waypaper
2. Waypaper: User selects image, saves to `~/.config/waypaper/`
3. Script: Detects change, calls `matugen image <path>`
4. Matugen: Generates colors, renders all templates
5. Post-hooks: Reload Hyprland, Kitty, Btop, etc.
6. Result: Entire desktop adapts to new color scheme instantly

### Extension Points

**For Users**:
1. **Custom Configuration Files**: Never touch defaults
2. **Variation System**: Choose from presets
3. **Theme Scripts**: Create custom themes in `~/.config/ml4w/themes/`
4. **Settings Scripts**: Modify app launchers in `~/.config/ml4w/settings/`
5. **Listeners**: Add custom background tasks in `~/.config/ml4w/listeners/`

**For Developers**:
1. **Matugen Templates**: Add new applications to color system
2. **Waybar Modules**: Create custom modules in `modules.json`
3. **.dotinst Format**: Package custom dotfiles
4. **ML4W Scripts**: Contribute utilities
5. **Themes**: Design new visual themes

### File Organization Philosophy

**Modularity**: Each component is self-contained
- Hyprland config split into 20+ files
- Shell configs in separate modules
- Waybar modules in dedicated JSON

**Discoverability**: Clear naming and structure
- `conf/` for configurations
- `scripts/` for scripts
- `themes/` for themes
- `settings/` for user-selectable options

**User Safety**: Multiple protection layers
- Default configs never modified
- User changes in separate files
- Backup/restore via .dotinst
- Protected files list for sync

**Maintainability**: Easy updates
- User configs separate from defaults
- Version-controlled defaults
- Automatic sync system for development
- Clear documentation in comments

---

## Conclusion

ML4W Dotfiles represents a **production-ready, professional desktop environment** for Hyprland that balances several competing goals:

**Sophistication**: Material Design 3 theming, advanced animations, comprehensive feature set

**Usability**: GUI applications, helper scripts, extensive keybindings

**Customizability**: Variation system, theme support, modular architecture

**Safety**: Protected user configs, backup/restore, non-destructive updates

**Integration**: Every component works together through the Matugen color system

**Cross-Distribution**: Works on Arch, Fedora, OpenSUSE

The project is particularly notable for:
- **Matugen Integration**: Best-in-class adaptive color theming
- **Custom Flatpak Apps**: Professional settings/configuration GUIs
- **Installation System**: .dotinst format with GUI installer
- **Developer Experience**: Sync daemon, clear architecture, extensive comments

This is not just a dotfiles collection—it's a **complete desktop operating system** built on Hyprland, with the polish and feature set of a major desktop environment.

**Target Audience**:
- Users wanting a complete, beautiful Hyprland setup out of the box
- Tiling WM beginners who need extensive helper apps
- Advanced users who appreciate Material Design aesthetics
- Anyone wanting adaptive color theming across their entire desktop

**Project Philosophy**: \"Make Hyprland accessible and beautiful for everyone, while respecting user customization.\"

---

**Analysis Complete**
