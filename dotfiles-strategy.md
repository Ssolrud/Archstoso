# Custom Dotfiles Strategy Document

**Project name**: ArchStoso
**Based on**: ML4W Dotfiles v2.10.1 analysis
**Goal**: Create a personal, rebranded dotfiles setup inspired by ML4W
**Maintenance**: Manual uploads to GitHub
**Namespace**: `~/.config/archstoso/` (replaces `~/.config/ml4w/`)

---

## Status Tracker

| Chapter | Status |
|---------|--------|
| 1. Hyprland Configuration | Done |
| 2. Waybar | Done |
| 3. Application Launcher | Done |
| 4. Kitty Terminal | Done |
| 5. Shell Configurations | Done |
| 6. Oh My Posh | Done |
| 7. Neovim | Done |
| 8. GTK/Qt Theming | Done |
| 9. Matugen Color System | Done |
| 10. Fastfetch | Done |
| 11. Btop | Done |
| 12. NWG Dock | Done |
| 13. Custom Apps & Scripts | Done |
| 14. Setup & Installation System | Done |
| 15. Miscellaneous Components | Done |
| 16. Architecture & Integration | Done |

---

## 1. Hyprland Configuration

**Structure**: Semi-modular (5-7 files)
- `core.conf` — monitor, keyboard, cursor settings
- `environment.conf` — all env vars (keep full set: XDG, QT, GTK, Mozilla, Electron, SDL, cursor)
- `appearance.conf` — decorations, animations, colors
- `keybindings.conf` — keep ML4W's full keybinding set, tweak as needed
- `windowrules.conf` — comprehensive rules for common apps (pavucontrol, blueman, PiP, calculator, etc.)
- `autostart.conf` — full autostart (polkit, swaync, hypridle, cliphist, wallpaper, GTK sync)
- `custom.conf` — personal overrides

**Variation system**: Keep full variation support (alternative animation presets, decoration presets, etc.)

**Hypridle**: Keep 4-stage progressive idle (dim 8min, lock 10min, screen off 11min, suspend 30min)

**Hyprlock**: Keep Material Design lock screen with blurred wallpaper

**Key difference from ML4W**: Fewer files (grouped by concern) but same feature depth. No ML4W-specific branding/scripts in the Hyprland layer.

---

## 2. Waybar

**Theme system**: Keep but reduced to 2 themes: `modern` and `minimal`
- Theme switcher script (simplified, only 2 options)
- Keybind to switch between them

**Layout**: Keep ML4W's default arrangement
- Left: app menu + window title
- Center: workspaces (5 persistent, scroll to cycle)
- Right: updates, audio, bluetooth, network, battery, hardware group, tools group, tray, notifications, exit, clock

**Drawer groups**: Keep collapsible groups
- Hardware group: system, disk, cpu, memory, language
- Tools group: clipboard, hypridle, hyprshade, power profiles

**Custom modules** (keep all four):
- System updates counter (with click-to-install)
- Now playing / media controls
- Clipboard manager (cliphist frontend)
- Hypridle inhibitor toggle

**Standard modules**: clock, network, battery, pulseaudio, bluetooth, backlight, power-profiles, tray

**Styling**: Matugen-generated `colors.css` (depends on Chapter 9 decision)

**Key difference from ML4W**: 2 themes instead of 8. No ML4W sidebar/welcome icon in bar. Same module set otherwise.

---

## 3. Application Launcher

**Launcher**: Walker only (no Rofi)
- Wayland-native, modern, Rust-based
- Better Hyprland integration
- Matugen color support via CSS

**Layout**: Two-column design with wallpaper integration (port ML4W's Rofi aesthetic to Walker)

**Specialized configs**: Keep all use-case-specific configs
- Clipboard history view
- Screenshot mode selection
- Hyprshade shader selection
- OCR language selection
- Theme selection
- Compact/short variants

**Styling**: Matugen-generated colors

**Key difference from ML4W**: Walker instead of Rofi. Need to recreate the specialized config variants in Walker's TOML/CSS format. No Rofi fallback.

**Note**: Walker is newer - verify package availability and stability. May need to build from source or use AUR.

---

## 4. Kitty Terminal

**Keep as-is** from ML4W:
- Font: JetBrainsMono Nerd Font, size 12
- Background opacity: 0.7 with dynamic opacity (runtime keyboard toggle)
- Cursor: blinking with cursor trail animation
- Colors: Matugen-generated (`colors-matugen.conf`)
- Window: 950x500, no decorations, 10px padding
- Scrollback: 2000 lines, no audio bell
- System clipboard integration
- `custom.conf` override support

**No changes needed** - ML4W's Kitty config is clean and well-structured.

---

## 5. Shell Configurations

**Shell**: Bash only (no zsh/fish configs)

**Structure**: Keep modular system
- `~/.bashrc` as loader, sources files from `~/.config/bashrc/`
- `00-init` — PATH, EDITOR, environment setup
- `10-aliases` — minimal aliases only
- `20-customization` — prompt (Oh My Posh)
- Custom override folder: `~/.config/bashrc/custom/`

**Aliases**: Minimal set
- Navigation: `..`, `c` (clear)
- Editor: `v`/`vim` -> $EDITOR
- System: `shutdown`, `lock`
- Add more as needed over time

**Dropped**: eza aliases, git shortcuts, ML4W flatpak aliases, fish/zsh support

**Key difference from ML4W**: Single shell, minimal aliases. Same modular file structure.

---

## 6. Oh My Posh

**Keep as-is** from ML4W:
- Oh My Posh with Zen theme (`~/.config/ohmyposh/zen.toml`)
- Two-line prompt: path + git (line 1), `❯` arrow (line 2)
- Right-side execution time (>5s threshold)
- Transient prompt (collapses after command)
- Matugen color integration via `colors.json`

**No changes needed.**

---

## 7. Neovim

**Keep minimal config** from ML4W:
- Basic settings: line numbers, tabs=4 spaces, system clipboard, mouse support
- Transparent background (matches terminal opacity)
- No plugins — add your own plugin manager/plugins as needed
- `init.vim` format (not lua)

**No changes needed.**

---

## 8. GTK/Qt Theming

**Keep full config** for GTK 2/3/4 and Qt6:
- GTK theme: Adwaita (dark mode enabled)
- Icon theme: Colloid-Dark
- Font: Fira Sans Semi-Bold 11
- Cursor: configurable (ArcStarry-cursors default)
- Font rendering: antialiasing + slight hinting
- Qt6: Breeze style, dark color scheme, via qt6ct
- Matugen color CSS generated for GTK 3/4

**Config files**:
- `~/.config/gtk-3.0/settings.ini`
- `~/.config/gtk-4.0/settings.ini`
- `~/.gtkrc-2.0`
- `~/.config/qt6ct/qt6ct.conf`

**No changes from ML4W defaults.**

---

## 9. Matugen Color System

**Keep full Matugen system** with all targets.

**Template targets** (all kept):
- Hyprland (`colors.conf`) + post-hook: `hyprctl reload`
- Waybar (`colors.css`)
- Walker (`colors.css`) — replaces Rofi target
- Kitty (`colors-matugen.conf`) + post-hook: `pkill -SIGUSR1 kitty`
- Btop (`matugen.theme`) + post-hook: `pkill -USR2 btop`
- GTK 3 (`colors.css`)
- GTK 4 (`colors.css`)
- SwayNC (`colors.css`)
- Wlogout (`colors.css`)
- NWG Dock (`colors.css`)
- Oh My Posh (`colors.json`) + post-hook: jq merge
- Hyprlock (via Hyprland colors)

**Color extraction**: Keep individual color files (`primary`, `secondary`, `onsurface`, `onprimary`) for scripts

**Workflow**: Wallpaper change -> matugen generates MD3 palette -> all templates rendered -> post-hooks reload apps -> instant desktop-wide color update

**Adaptation needed**: Replace Rofi template with Walker template. Remove any ML4W-specific template references.

---

## 10. Fastfetch

**Keep but rebrand**:
- Same bordered box layout with colored icons
- Same modules: user, hostname, OS age, uptime, distro, kernel, WM, desktop, terminal, shell, CPU, disk, memory, colors
- Replace ML4W logo with custom/personal logo
- Keep OS age calculator (days since install)

---

## 11. Btop

**Keep as-is** from ML4W:
- Matugen-generated theme
- Braille graph characters
- Rounded corners, truecolor
- 2-second update interval
- CPU lazy sorting
- Shown boxes: cpu, mem, net, proc

---

## 12. NWG Dock

**Skipped** — not included in dotfiles. Use Waybar + keybinds for app launching.

Remove dock-related items:
- No `~/.config/nwg-dock-hyprland/` config
- Remove dock Matugen template
- Remove dock theme references from theme scripts

---

## 13. Custom Apps & Scripts

**Approach**: Keep all functionality but **fully rebrand** — no direct ML4W references anywhere.

### Custom Apps (Flatpak — rebranded)
Keep all 5 apps, rebrand identifiers and UI:
- Welcome/onboarding app
- Settings manager GUI
- Calendar widget
- Information sidebar
- Hyprland settings GUI

All `com.ml4w.*` references renamed to personal branding.

### Listeners
**Keep both**:
- GTK theme sync (keeps GTK 2/3/4 consistent on theme change)
- Low battery notification

### App Selectors
**Use environment variables** instead of ML4W's script-per-app pattern:
- Set `$BROWSER`, `$TERMINAL`, `$EDITOR`, `$FILE_MANAGER` in shell init
- Keybindings reference env vars directly
- Simpler, follows standard Linux conventions

### Theme Presets
**Keep theme preset system**:
- One `theme.sh` script per preset switches: Waybar theme, SwayNC style, wlogout style, window borders, launcher styling
- Pairs with the variation system (Chapter 1)
- Remove dock-switching from theme scripts (no dock)

### Scripts Directory
Rebrand all `ml4w-*` prefixed scripts. Keep functionality:
- System update checker/installer
- Clipboard history manager
- Wlogout launcher
- Sidepad manager
- Now playing / media status
- Screenshot tools
- Theme toggler
- Shell changer
- Network tools

### Directory Structure
Rename `~/.config/ml4w/` to personal namespace:
```
~/.config/<your-brand>/
├── assets/
├── colors/
├── library.sh
├── listeners/
├── listeners.sh
├── scripts/
├── settings/
├── themes/
├── version.json
└── wallpapers/
```

---

## 14. Setup & Installation System

**Method**: Simple bash install script (no .dotinst, no Flatpak installer)

**Distro support**: Arch Linux only (pacman + AUR helper)

**Install script features**:
- Package installation via pacman and AUR helper (yay/paru)
- Copy/symlink config files to `~/.config/`
- Package list as plain text file (one per line)
- Optional backup of existing configs before overwriting
- No first-time settings wizard (configure manually after install)

**Dropped from ML4W**:
- .dotinst format and Flatpak GUI installer
- Multi-distro setup scripts (Fedora, openSUSE)
- Restoration system
- Settings wizard
- `gum` dependency (use plain bash prompts)

**Package list**: Single `packages.txt` organized by section comments

---

## 15. Miscellaneous Components

### SwayNC — Keep
- Full notification center with control center (360x700, top-right)
- Widgets: DND toggle, buttons grid, backlight, volume, MPRIS
- Wi-Fi/Bluetooth toggles
- Matugen colors + theme-based styling
- Blur via Hyprland layer rules

### Wlogout — Keep
- Graphical power menu (logout, lock, suspend, hibernate, reboot, shutdown)
- Matugen color integration
- Theme-specific styles

### Waypaper — Keep full integration
- GUI wallpaper picker
- Triggers Matugen color generation on wallpaper change
- Generates blurred wallpaper for lock screen
- Caching system for wallpaper variants
- Wallpaper restore on login
- Wallpaper automation (auto-rotation)

### Sidepad — Keep
- Retractable side panel
- Keybindings: SUPER+CTRL+Right/Left to show/hide

### Browser Flags — Keep
- Chromium Wayland flags (`chromium-flags.conf`)
- Edge Wayland flags (`edge-flags.conf`)
- Forces native Wayland for better performance

### Hyprland Scripts — Keep all
- cleanup, focus, gamemode, gtk, hypridle, hyprshade
- keybindings viewer, launcher, loadconfig, moveTo
- power, screenshot, text-extractor (OCR), toggle-animations
- wallpaper-automation, wallpaper-effects, wallpaper-cache, wallpaper-restore

All scripts rebranded (remove ml4w references).

---

## 16. Architecture & Integration

### Config Hierarchy (3 levels)
1. **Core defaults** — Base configs in the repo, not to be edited directly
2. **Variations** — Alternative presets (animation styles, decoration themes) you swap between
3. **Custom overrides** — `custom.conf` files for personal tweaks that survive updates

### Repo Structure
Mirror `~/.config/` layout:
```
dotfiles/
├── hypr/                    # Hyprland configs
│   ├── hyprland.conf
│   ├── conf/
│   │   ├── core.conf
│   │   ├── environment.conf
│   │   ├── appearance.conf
│   │   ├── keybindings.conf
│   │   ├── windowrules.conf
│   │   ├── autostart.conf
│   │   └── custom.conf
│   ├── conf/animations/     # Variation presets
│   ├── conf/decorations/
│   ├── scripts/
│   ├── hypridle.conf
│   └── hyprlock.conf
├── waybar/
│   ├── themes/modern/
│   ├── themes/minimal/
│   ├── modules.json
│   └── launch.sh
├── walker/                  # Launcher (replaces rofi)
├── kitty/
├── matugen/
│   └── templates/
├── archstoso/                 # Replaces ml4w/
│   ├── scripts/
│   ├── settings/
│   ├── themes/
│   ├── listeners/
│   └── assets/
├── swaync/
├── wlogout/
├── btop/
├── fastfetch/
├── ohmyposh/
├── nvim/
├── bashrc/                  # Modular shell configs
├── gtk-3.0/
├── gtk-4.0/
├── qt6ct/
├── sidepad/
├── packages.txt             # Arch package list
└── install.sh               # Simple install script
```

### Versioning
- Git tags only (e.g., `v1.0`, `v1.1`)
- No version.json file in configs
- Manual GitHub uploads

### Color Pipeline (unchanged from ML4W concept)
```
Wallpaper (waypaper) -> Matugen -> Color templates -> Post-hooks -> Unified theme
```

### Key Differences from ML4W Summary
- **Rebranded**: No ml4w references, personal namespace
- **Walker**: Replaces Rofi as launcher
- **No dock**: NWG Dock removed
- **Env vars**: $BROWSER/$TERMINAL instead of selector scripts
- **Arch only**: No multi-distro support
- **Simple installer**: Bash script, no .dotinst
- **Fewer Waybar themes**: 2 instead of 8
- **Semi-modular Hyprland**: 5-7 files instead of 15+
- **Bash only**: No zsh/fish configs
- **Git tags**: No version.json
