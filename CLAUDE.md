# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Linux desktop environment configuration workspace containing:

- **ArchStoso Dotfiles** (`dotfiles/`): Personal Hyprland desktop environment dotfiles for Arch Linux, inspired by ML4W but fully rebranded. **Build complete. Post-install fixes applied — see Known Issues & Fixes below.**
- **ML4W Dotfiles** (`mylinuxforwork-dotfiles/`): Reference project — comprehensive Hyprland dotfiles (GPLv3). Analysis in `ml4w-dotfiles-analysis.md`. Used as inspiration source.
- **ArchTitus** (`ArchTitus/`): Automated Arch Linux installer by ChrisTitusTech (MIT license, project has moved to LinUtil)
- **system-status.sh**: Local hardware/software audit script for the host system

The root directory is not a git repo. Subprojects have their own git repos.

## ArchStoso Dotfiles — Build Progress

**Build plan**: `.claude/plans/curious-twirling-lemon.md`
**Strategy doc**: `dotfiles-strategy.md` (all 16 chapters of decisions)
**ML4W analysis**: `ml4w-dotfiles-analysis.md`

### Completed Phases (292 files built)

| Phase | Status | What was done |
|-------|--------|---------------|
| 1. Hyprland core | DONE | Semi-modular config (7 conf files), all variation presets (animations, decorations, windows, monitors, environments, layouts, workspaces, keybindings, windowrules), hypridle, hyprlock, colors.conf, 25 scripts. All rebranded. |
| 2. Matugen + Kitty + Shell + OMP | DONE | matugen/config.toml (removed rofi+dock templates, rebranded paths), all templates, kitty.conf, bashrc modular configs (00-init, 10-aliases, 20-customization), ohmyposh/zen.toml |
| 3. Waybar (2 themes) | DONE | modules.json, launch.sh, themeswitcher.sh, toggle.sh, colors.css, themes/modern/ and themes/minimal/. All rebranded. |
| 4. Walker launcher | DONE | config.toml, launch.sh, themes/. Copied and rebranded from ML4W. |
| 5. ArchStoso core | DONE | 92 files: library.sh, listeners.sh, 2 listeners (gtk-theme-switcher, low-bat), 21 scripts (14 top-level + 7 arch/), 42 settings files, 3 theme files (themes.sh, modern/theme.sh, minimal/theme.sh), 4 color seeds, 11 wallpapers, version.json, 5 bin/ fzf utilities. All rebranded, zero ml4w refs. |
| 6. Supporting apps | DONE | 43 files: swaync/ (9 files, 2 themes), wlogout/ (14 files, 3 themes + icons), gtk-3.0/ (3), gtk-4.0/ (3), qt6ct/ (1), btop/ (2, matugen theme), fastfetch/ (1, rebranded asset path), nvim/ (1), sidepad/ (5, rebranded pad names), chromium-flags.conf, edge-flags.conf, assets/ (2, placeholder logo). All rebranded, zero ml4w refs. |

| 7. Install script | DONE | 2 files: install.sh (~280 lines, Arch-only, pacman+AUR, backup+copy, --dry-run support, env var setup) and packages.txt (73 packages: 66 pacman + 7 AUR). All rebranded, zero ml4w refs. |

### All Phases Complete

### Rebranding Pattern

When continuing the build, apply these replacements to all files copied from ML4W:
- `ml4w` → `archstoso`, `ML4W` → `ArchStoso`
- `com.ml4w.` → `com.archstoso.`
- `~/.config/ml4w/` → `~/.config/archstoso/`
- `ml4w-*` script names → `archstoso-*`
- `ml4w_cache_folder` → `archstoso_cache_folder`
- `ml4w/hyprland-dotfiles` → `archstoso/hyprland-dotfiles`
- Remove nwg-dock references (dock was dropped)
- Remove rofi references (Walker only)
- App launchers use env vars ($BROWSER, $TERMINAL, $FILE_MANAGER) not selector scripts

### Key Source Paths (ML4W reference)

- ML4W scripts: `mylinuxforwork-dotfiles/dotfiles/.config/ml4w/scripts/`
- ML4W listeners: `mylinuxforwork-dotfiles/dotfiles/.config/ml4w/listeners/`
- ML4W themes: `mylinuxforwork-dotfiles/dotfiles/.config/ml4w/themes/`
- ML4W settings: `mylinuxforwork-dotfiles/dotfiles/.config/ml4w/settings/`
- ML4W library: `mylinuxforwork-dotfiles/dotfiles/.config/ml4w/library.sh`
- SwayNC: `mylinuxforwork-dotfiles/dotfiles/.config/swaync/`
- Wlogout: `mylinuxforwork-dotfiles/dotfiles/.config/wlogout/`
- GTK/Qt: `mylinuxforwork-dotfiles/dotfiles/.config/gtk-3.0/`, `gtk-4.0/`, `qt6ct/`
- Btop: `mylinuxforwork-dotfiles/dotfiles/.config/btop/`
- Fastfetch: `mylinuxforwork-dotfiles/dotfiles/.config/fastfetch/`
- Nvim: `mylinuxforwork-dotfiles/dotfiles/.config/nvim/`
- Sidepad: `mylinuxforwork-dotfiles/dotfiles/.config/sidepad/`

## ArchStoso Dotfiles — Key Decisions

Full strategy in `dotfiles-strategy.md`. Summary:

### Stack
- **WM**: Hyprland (semi-modular config: 7 conf files instead of ML4W's 15+)
- **Bar**: Waybar (2 themes: modern + minimal)
- **Launcher**: Walker (Wayland-native, replaces ML4W's Rofi)
- **Terminal**: Kitty (unchanged from ML4W)
- **Colors**: Matugen (full integration across all components)
- **Prompt**: Oh My Posh with Zen theme
- **Notifications**: SwayNC
- **Power menu**: Wlogout
- **Editor**: Neovim (minimal config)
- **Wallpaper**: swww + waypaper (hyprpaper was dropped — did not work reliably)

### Architecture
- **Namespace**: `~/.config/archstoso/` (replaces `~/.config/ml4w/`)
- **Config hierarchy**: 3 levels (defaults → variations → custom.conf overrides)
- **Repo structure**: Mirrors `~/.config/` layout in `dotfiles/`
- **App defaults**: Environment variables ($BROWSER, $TERMINAL, $EDITOR) instead of selector scripts
- **Shell**: Bash only (modular configs in `~/.config/bashrc/`)
- **Install**: Simple bash script, Arch-only, pacman + AUR
- **Versioning**: Git tags only
- **No dock**: NWG Dock removed
- **Rebranded**: All `ml4w` references replaced with `archstoso`

## Claude Agent System

A custom agent is defined at `.claude/agents/archlinux-hyprland-expert.md` for Arch Linux and Hyprland expertise. It has persistent memory at `.claude/agent-memory/`. This agent is automatically invoked for Linux/Arch/Hyprland questions.

## Linting

Shell scripts should follow shellcheck conventions.

## Key Conventions

- All code is pure bash shell scripts — no compiled languages or package managers (npm, cargo, etc.)
- Package lists are plain text files (one package per line)
- ArchStoso configs use `custom.conf` files for user overrides (never edit defaults directly)
- When resuming the build, always verify rebranding with: `grep -ri "ml4w" dotfiles/`

## Known Issues & Fixes

### nwg-displays stub files (FIXED)
`dotfiles/hypr/conf/monitors/nwg-displays.conf` sources two files that `nwg-displays` generates at runtime:
- `~/.config/hypr/monitors.conf`
- `~/.config/hypr/workspaces.conf`

These do not exist on a fresh install, causing Hyprland to throw `source= globbing error` before `keybindings.conf` loads — resulting in **zero hotkeys working**.

**Fix applied**: Added stub files to the dotfiles repo:
- `dotfiles/hypr/monitors.conf` → `monitor = ,preferred,auto,1`
- `dotfiles/hypr/workspaces.conf` → empty

These are copied by `install.sh` (which copies the full `hypr/` directory). `nwg-displays` will overwrite them with generated content when first run.

**Hyprland log location**: `/run/user/1000/hypr/<signature>/hyprland.log` (not `~/.local/share/hyprland/`)

### Hyprland config variables vs shell env vars (FIXED)
`$TERMINAL`, `$BROWSER`, `$FILE_MANAGER` in keybindings are **Hyprland config variables**, not shell env vars. They must be explicitly assigned in the config or they expand to empty string (bind fires, nothing runs).

**Fix applied**: Added defaults to `dotfiles/hypr/conf/keybindings/default.conf` after `$SCRIPTS = ...`:
```ini
$TERMINAL     = kitty
$BROWSER      = firefox
$FILE_MANAGER = thunar
```

Users can override these in `~/.config/hypr/conf/custom.conf`.

### Waybar missing from autostart (FIXED)
`autostart.conf` was missing `exec-once = ~/.config/waybar/launch.sh`. Waybar never started on session entry.

**Fix applied**: Added `exec-once = ~/.config/waybar/launch.sh` to `dotfiles/hypr/conf/autostart.conf`.

### Wallpaper not showing — hyprpaper replaced with swww (FIXED)
`hyprpaper` started but never applied the wallpaper (IPC protocol mismatch with the waypaper integration). `swww` works correctly.

**Fix applied**:
- `hyprpaper` removed from `packages.txt`
- `swww-daemon` added to `autostart.conf` (before `wallpaper-restore.sh`)
- `dotfiles/waypaper/config.ini` created with `backend = swww`
- `waypaper` added to `install.sh` copy list
- `wallpaper-restore.sh` has `sleep 2` before calling waypaper (prevents race condition at startup)

### Walker launcher shows no apps (FIXED)
Walker uses `elephant` as its data backend. Providers are separate AUR packages — without them `elephant listproviders` returns nothing and Walker shows no results.

**Architecture**: `walker-bin` (UI frontend) + `elephant` (data daemon) + provider packages (plugins per data source).

**Fix applied**:
- `packages.txt` lists three source-variant provider packages (AUR section):
  - `elephant-desktopapplications` — scans `.desktop` files
  - `elephant-websearch` — websearch provider
  - `elephant-providerlist` — provider switcher
  - **Do not use `-bin` variants** — they conflict with the `elephant` source package
- `install.sh` runs `elephant service enable && systemctl --user start elephant.service` after AUR install
- `dotfiles/hypr/conf/environment.conf` sets:
  ```ini
  env = XDG_DATA_DIRS,/home/daystoso/.local/share:/usr/local/share:/usr/share
  ```
- `dotfiles/walker/launch.sh` has a fallback: starts `elephant &` if the service is not running

**Debugging**: Run `elephant listproviders` — if empty, providers are not installed. Check `systemctl --user status elephant.service`.

### Keyboard layout and monitor scaling in custom.conf
User-specific overrides live in `dotfiles/hypr/conf/custom.conf` (never overwritten by installs):
```ini
input {
    kb_layout = no
}
monitor = ,preferred,auto,1.5
```

### Samsung C49RG9x via HP Thunderbolt Dock G4 — FIXED (3840x1080@59.97)
Samsung C49RG9x 49" ultrawide (native 5120x1440) is connected via HP Thunderbolt Dock G4 on connector DP-6.

**Hardware:**
- GPU: Intel UHD (CometLake-H GT2, Gen 9.5 display engine) + NVIDIA GTX 1650 Ti (Optimus, not used for display)
- TB controller: JHL7540 Titan Ridge 4C 2018 + Goshen Ridge TB4 bridge
- Dock MST hub: Synaptics SYNAS (OUI: 90cc24, sw: 5.7), 4 ports, 63 MST slots

**Root cause: Gen 9.5 display engine plane width hard limit of 4096px**

Confirmed via DRM debug (`echo 0x14 > /sys/module/drm/parameters/debug`) on 2026-02-22:
```
[drm:skl_plane_check [i915]] [PLANE:57:plane 1B] requested Y/RGB source size 5120x1440 outside limits (min: 1x1 max: 4096x4096)
```
The `skl_plane_check` function in i915 enforces a **4096px max width** for all non-YUV formats on Skylake/Comet Lake display engines. 5120 > 4096 → permanent EINVAL. No modifier fix, kernel parameter, or env var can overcome this — it is the display engine silicon.

**Things that do NOT fix it (confirmed dead ends):**
- `AQ_DRM_DISABLE_MODIFIERS=1` — does not prevent Y_TILED_CCS GBM allocation; only affects FB import step; ineffective
- `~/.config/environment.d/50-aq-display.conf` — loaded correctly but irrelevant to root cause
- Disabling eDP-1 — does not help; plane width is a per-plane limit, not dual-display bandwidth
- Any MST/bandwidth tuning — bandwidth is sufficient; the limit is display engine geometry

**Best fallback: 3840x1080 (same 32:9 aspect ratio as native)**

3840 < 4096 → passes plane check. Same 32:9 aspect ratio as 5120x1440 → fills the full screen with no black bars.

Modes available: `3840x1080@119.97Hz` (preferred), `3840x1080@99.96Hz`, `3840x1080@59.97Hz`

The 120Hz mode may fail due to CDCLK/watermark — use 60Hz:
```ini
monitor = DP-6, 3840x1080@59.97, auto, 1.0
```

**Current state of custom.conf:** Still has `5120x1440` — update to `3840x1080@59.97` once confirmed working.

**To clean up (no longer needed):**
- `env = AQ_DRM_DISABLE_MODIFIERS,1` in `environment.conf` — can be removed
- `~/.config/environment.d/50-aq-display.conf` — can be removed
