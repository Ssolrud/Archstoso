# ArchStoso

A personal Hyprland desktop environment for Arch Linux.

**Stack:** Hyprland · Waybar · Walker · Kitty · Matugen · swww · SwayNC · Wlogout · Oh My Posh

---

## Requirements

- A fresh Arch Linux install with a user account (not root)
- Internet connection
- `git` installed (`sudo pacman -S git`)

---

## Installation

### 1. Clone the repo

```bash
git clone https://github.com/Ssolrud/Archstoso.git
cd Archstoso/dotfiles
```

### 2. (Optional) Preview what will happen

```bash
bash install.sh --dry-run
```

### 3. Run the installer

```bash
bash install.sh
```

The script will:
- Install all packages via `pacman` and an AUR helper (`yay` or `paru` — installed automatically if missing)
- Back up any existing configs to `~/.config-backup-archstoso-<timestamp>`
- Copy all dotfiles to `~/.config/`
- Set up environment variables in `~/.bashrc`
- Enable the Walker/elephant launcher service

### 4. Start Hyprland

Log out and select **Hyprland** from your display manager, or run:

```bash
uwsm start hyprland
```

---

## After Install

### Set your wallpaper

```bash
waypaper
```

### Personal overrides

Edit `~/.config/hypr/conf/custom.conf` — this file is never overwritten by updates:

```ini
# Example: Norwegian keyboard layout + monitor scaling
input {
    kb_layout = no
}
monitor = ,preferred,auto,1.5
```

### Monitor configuration

Use `nwg-displays` (GUI) to configure your monitors. It will generate
`~/.config/hypr/monitors.conf` and `~/.config/hypr/workspaces.conf` automatically.

---

## Gaming

### Additional packages

These are not included in `packages.txt` and must be installed manually:

```bash
sudo pacman -S gamemode mangohud
```

- `gamemode` — CPU/system-level performance optimizations (by Feral Interactive)
- `mangohud` — in-game performance overlay (FPS, CPU, GPU, VRAM)

### Hyprland gamemode

ArchStoso includes a built-in script that disables compositor effects for maximum performance:

- Disables animations, blur, shadows
- Removes window gaps and rounding
- Restores everything when toggled off

**Keybind:** `Super + Alt + G`

You will get a desktop notification when it activates and deactivates.

### Steam launch options

Add this to each game's launch options in Steam (**Properties → General → Launch Options**):

```
~/.config/hypr/scripts/gamemode.sh && prime-run gamemoderun mangohud %command% ; ~/.config/hypr/scripts/gamemode.sh
```

What each part does:

| Part | What it does |
|------|-------------|
| `~/.config/hypr/scripts/gamemode.sh` (first) | Disables Hyprland compositor effects before the game starts |
| `prime-run` | Runs the game on the dedicated NVIDIA GPU (Optimus laptops) |
| `gamemoderun` | Applies system-level optimizations via the gamemode daemon |
| `mangohud` | Shows the performance overlay in-game |
| `%command%` | The actual game |
| `~/.config/hypr/scripts/gamemode.sh` (last) | Re-enables compositor effects after the game exits |

> Remove `prime-run` if you are on a desktop with only one GPU.

---

## Packages

73 packages total — 66 from pacman, 7 from AUR. See [`dotfiles/packages.txt`](dotfiles/packages.txt) for the full list.

Notable AUR packages:
- `walker-bin` + `elephant-*` — app launcher and its data providers
- `matugen-bin` — wallpaper-based color scheme generator
- `swww` / `waypaper` — wallpaper daemon and GUI
- `wlogout` — power/logout menu
- `nwg-displays` — monitor layout GUI

---

## License

Personal dotfiles — use freely. Inspired by [ML4W](https://github.com/mylinuxforwork/dotfiles) (GPLv3).
