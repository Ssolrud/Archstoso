# ArchStoso Post-Install QC Checklist

Run this after a fresh install to verify the dotfiles are working correctly.  
Work through each section and record PASS / FAIL / SKIP.

You can run this interactively with Claude Code (`claude` in the repo directory).  
Claude has specific instructions for guiding the QC — see `.claude/QC.md`.

**Legend**: ✅ PASS | ❌ FAIL | ⏭ SKIP | ⚠️ PARTIAL

---

## Before You Start

Log into a Hyprland session. Open a Kitty terminal (`SUPER+Return`).  
All commands are run in the terminal unless otherwise noted.

---

## Section 1 — Hyprland Session

| # | Check | Command / Action |
|---|-------|-----------------|
| 1.1 | Hyprland launched without errors | `cat /run/user/1000/hypr/*/hyprland.log \| grep -i error` |
| 1.2 | Monitor at correct resolution | `hyprctl monitors` |
| 1.3 | Wayland env vars set | `echo $WAYLAND_DISPLAY $XDG_SESSION_TYPE` |
| 1.4 | Terminal opens | Press `SUPER+Return` |
| 1.5 | Autostart programs running | `pgrep -a waybar swaync hypridle` |
| 1.6 | swww-daemon running | `pgrep swww-daemon` |
| 1.7 | Wallpaper restored on login | Visible on desktop after ~3s |
| 1.8 | Colors loaded | `hyprctl getoption general:col.active_border` (should not be 0xffffffff) |
| 1.9 | Config reload works | `SUPER+CTRL+R` or `hyprctl reload` |
| 1.10 | No globbing errors in log | `grep "globbing" /run/user/1000/hypr/*/hyprland.log` (should be empty) |

---

## Section 2 — Keybindings

| # | Shortcut | Expected |
|---|----------|----------|
| 2.1 | `SUPER+Return` | Opens Kitty |
| 2.2 | `SUPER+E` | Opens Thunar |
| 2.3 | `SUPER+B` | Opens Firefox |
| 2.4 | `SUPER+CTRL+Return` | Opens Walker launcher |
| 2.5 | `SUPER+Q` | Closes active window |
| 2.6 | `SUPER+CTRL+Q` | Opens wlogout power menu |
| 2.7 | `SUPER+1` through `SUPER+0` | Switches workspaces |
| 2.8 | `SUPER+Arrow keys` | Moves window focus |
| 2.9 | `SUPER+SHIFT+Arrow keys` | Moves window |
| 2.10 | `SUPER+F` | Toggles fullscreen |
| 2.11 | `SUPER+V` | Opens clipboard picker (Walker) |
| 2.12 | `SUPER+PRINT` | Opens screenshot menu (fuzzel) |
| 2.13 | `SUPER+ALT+S` | Instant area screenshot |
| 2.14 | `CTRL+ALT+T` | Opens theme switcher (fuzzel) |
| 2.15 | `SUPER+S` | Initialises sidepad |
| 2.16 | `SUPER+SHIFT+B` | Reloads Waybar |
| 2.17 | Function keys | Brightness and volume work |

---

## Section 3 — Waybar

| # | Check | Action |
|---|-------|--------|
| 3.1 | Bar visible at login | Visual check |
| 3.2 | Workspace indicators update | Switch workspaces |
| 3.3 | Clock/date correct | Visual check |
| 3.4 | System tray icons visible | Visual check |
| 3.5 | Network module shows status | Visual check |
| 3.6 | Audio module responds to scroll | Scroll on volume |
| 3.7 | Toggle bar works | `~/.config/waybar/toggle.sh` |
| 3.8 | Modern theme loads | `~/.config/archstoso/themes/modern/theme.sh` |
| 3.9 | Minimal theme loads | `~/.config/archstoso/themes/minimal/theme.sh` |
| 3.10 | Notification icon shows bell | Bell icon (not text) in bar |

---

## Section 4 — Walker Launcher

| # | Check | Command |
|---|-------|---------|
| 4.1 | Walker opens | `SUPER+CTRL+Return` |
| 4.2 | App list populated | `elephant listproviders` (should list ≥4) |
| 4.3 | Search filters results | Type an app name |
| 4.4 | Launching app works | Select and press Enter |
| 4.5 | Elephant service running | `systemctl --user status elephant.service` |
| 4.6 | XDG_DATA_DIRS set | `echo $XDG_DATA_DIRS \| grep .local/share` |

---

## Section 5 — Wallpaper System

| # | Check | Command |
|---|-------|---------|
| 5.1 | Wallpaper shows on login | Visual check |
| 5.2 | swww-daemon running | `pgrep swww-daemon` |
| 5.3 | waypaper backend is swww | `grep backend ~/.config/waypaper/config.ini` |
| 5.4 | Wallpaper folder setting | `cat ~/.config/archstoso/settings/wallpaper-folder` |
| 5.5 | waypaper GUI opens | `waypaper` |
| 5.6 | wallpaper.sh sets wallpaper | `~/.config/hypr/scripts/wallpaper.sh ~/.config/archstoso/wallpapers/default.jpg` |
| 5.7 | wallpaper-effects.sh opens menu | `~/.config/hypr/scripts/wallpaper-effects.sh` |
| 5.8 | Wallpaper cache created | `ls ~/.cache/archstoso/hyprland-dotfiles/` |

---

## Section 6 — Color/Theme System (Matugen)

| # | Check | Command |
|---|-------|---------|
| 6.1 | matugen installed | `which matugen` |
| 6.2 | matugen generates colors | `matugen image ~/.config/archstoso/wallpapers/default.jpg` |
| 6.3 | colors.conf updated | `head -5 ~/.config/hypr/colors.conf` |
| 6.4 | Kitty colors update | Visual check after matugen |
| 6.5 | Waybar colors update | Visual check — Waybar reloads automatically |
| 6.6 | SwayNC notification themed | `notify-send "Test" "color check"` |
| 6.7 | btop theme has colors | `grep "theme\[main_fg\]" ~/.config/btop/themes/matugen.theme` |
| 6.8 | Theme switcher works | `CTRL+ALT+T` — pick modern or minimal |
| 6.9 | GTK listener triggers matugen | Toggle `gtk-application-prefer-dark-theme` in `~/.config/gtk-3.0/settings.ini` |

---

## Section 7 — Notifications (SwayNC)

| # | Check | Command |
|---|-------|---------|
| 7.1 | swaync running | `pgrep swaync` |
| 7.2 | Notification appears | `notify-send "Test" "Hello"` |
| 7.3 | Notification center opens | Click bell icon in Waybar |
| 7.4 | Dismiss notification | Click X on notification |
| 7.5 | DND suppresses | Toggle DND, send notification |
| 7.6 | Critical styled differently | `notify-send -u critical "CRITICAL" "test"` — different border |

---

## Section 8 — Power Menu (Wlogout)

| # | Check | Action |
|---|-------|--------|
| 8.1 | Menu opens | `SUPER+CTRL+Q` |
| 8.2 | All 6 buttons visible | Lock / Logout / Reboot / Shutdown / Suspend / Hibernate |
| 8.3 | Icons render | Visual check |
| 8.4 | ESC closes menu | Press Escape |
| 8.5 | Lock button works | Click Lock — hyprlock appears, unlocks with password |

---

## Section 9 — Screenshot Tool

| # | Check | Action |
|---|-------|--------|
| 9.1 | Screenshot menu opens | `SUPER+PRINT` — fuzzel menu appears |
| 9.2 | Area screenshot works | `SUPER+ALT+S` — crosshair appears |
| 9.3 | Screenshot saved | `ls ~/Pictures/screenshot_*.jpg` |
| 9.4 | Screenshot in clipboard | After `SUPER+ALT+S`: `wl-paste --list-types` shows `image/png` |
| 9.5 | Filename format correct | `screenshot_YYYYMMDD_HHMMSS.jpg` |
| 9.6 | grimblast installed | `which grimblast` |

---

## Section 10 — Sidepad

| # | Check | Action |
|---|-------|--------|
| 10.1 | Init sidepad | `SUPER+S` — Kitty window appears on screen edge |
| 10.2 | Toggle open | `SUPER+CTRL+Right` |
| 10.3 | Toggle hide | `SUPER+CTRL+Left` |
| 10.4 | Pad selector | `SUPER+SHIFT+S` — fuzzel list of pads |
| 10.5 | Active pad setting | `cat ~/.config/archstoso/settings/sidepad-active` |
| 10.6 | Kill sidepad | `~/.config/archstoso/scripts/archstoso-sidepad --kill` |

---

## Section 11 — Screen Lock (Hyprlock)

| # | Check | Action |
|---|-------|--------|
| 11.1 | Lock screen appears | `hyprlock` |
| 11.2 | Unlocks with password | Type password + Enter |
| 11.3 | Lock screen shows wallpaper/clock | Visual check |

---

## Section 12 — Clipboard Manager

| # | Check | Command |
|---|-------|---------|
| 12.1 | wl-paste watch running | `pgrep -a wl-paste` — should show `wl-paste --watch cliphist store` |
| 12.2 | cliphist stores entries | Copy text, then `cliphist list \| head -3` |
| 12.3 | Walker clipboard shows history | `SUPER+V` — entries visible |
| 12.4 | Paste from history | Select entry → Ctrl+V pastes it |

---

## Section 13 — Terminal (Kitty)

| # | Check | Command |
|---|-------|---------|
| 13.1 | Kitty opens | `SUPER+Return` |
| 13.2 | Nerd Font icons render | `echo -e "\uf0f3"` — shows bell icon |
| 13.3 | Matugen colors applied | Warm tones visible after running matugen |
| 13.4 | custom.conf exists | `ls ~/.config/kitty/custom.conf` |

---

## Section 14 — Shell & Prompt

| # | Check | Command |
|---|-------|---------|
| 14.1 | Oh My Posh prompt active | Open Kitty — prompt shows `~❯` (Zen theme is minimal: dir + ❯) |
| 14.2 | oh-my-posh installed | `which oh-my-posh` |
| 14.3 | Modular bashrc loaded | `ls ~/.config/bashrc/` — shows 00-init, 10-aliases, 20-customization |
| 14.4 | Aliases loaded | `alias` — shows c, v, nf, lock etc. |

---

## Section 15 — Listeners

| # | Check | Command |
|---|-------|---------|
| 15.1 | Start all listeners | `~/.config/archstoso/listeners.sh --startall` |
| 15.2 | Status shows running | `~/.config/archstoso/listeners.sh --status` |
| 15.3 | GTK listener triggers matugen | Toggle `gtk-application-prefer-dark-theme`, Waybar updates |
| 15.4 | Stop all | `~/.config/archstoso/listeners.sh --stopall` |
| 15.5 | Restart one | `~/.config/archstoso/listeners.sh --restart gtk-theme-switcher` |

---

## Section 16 — Bin Utilities

| # | Check | Command |
|---|-------|---------|
| 16.1 | archstoso-apps | `~/.config/archstoso/bin/archstoso-apps.sh` |
| 16.2 | archstoso-wallpaper | `~/.config/archstoso/bin/archstoso-wallpaper.sh` (needs files in `~/wallpaper`) |
| 16.3 | archstoso-screenshot | `~/.config/archstoso/bin/archstoso-screenshot.sh` |
| 16.4 | archstoso-quicklinks | `~/.config/archstoso/bin/archstoso-quicklinks.sh` (graceful if `~/.quicklinks` missing) |
| 16.5 | archstoso-finder | `~/.config/archstoso/bin/archstoso-finder.sh` |

---

## Section 17 — System Scripts

| # | Check | Command |
|---|-------|---------|
| 17.1 | check-system-updates | `~/.config/archstoso/scripts/archstoso-check-system-updates` (outputs JSON) |
| 17.2 | wlogout script | `~/.config/archstoso/scripts/archstoso-wlogout` |
| 17.3 | toggle-theme | `~/.config/archstoso/scripts/archstoso-toggle-theme` |
| 17.4 | network | `~/.config/archstoso/scripts/archstoso-network` (opens nmtui) |
| 17.5 | notification-handler | `source ~/.config/archstoso/scripts/archstoso-notification-handler && notify_user --s "Test" --m "QC"` |
| 17.6 | ascii-header | `~/.config/archstoso/scripts/archstoso-ascii-header` |

---

## Section 18 — GTK/Qt/Fonts

| # | Check | Action |
|---|-------|--------|
| 18.1 | Thunar follows dark theme | Open Thunar (`SUPER+E`) — dark background |
| 18.2 | Qt6 theme | Open `qt6ct` — themed correctly |
| 18.3 | Nerd Font icons in Waybar | Bell icon, workspace icons render |
| 18.4 | nwg-look | `nwg-look` — opens, shows current theme |

---

## Section 19 — Game Mode *(optional)*

Requires `gamemode` and `mangohud` packages (not installed by default).

| # | Check | Action |
|---|-------|--------|
| 19.1 | Toggle on | `ALT+G` — animations disabled |
| 19.2 | Toggle off | `ALT+G` again — animations return |

---

## Section 20 — Fastfetch / Btop

| # | Check | Command |
|---|-------|---------|
| 20.1 | Fastfetch displays info | `fastfetch` — Arch logo, no ml4w refs |
| 20.2 | Btop opens | `btop` |
| 20.3 | Btop matugen theme | Dark themed colors matching current palette |

---

## Known Gotchas

These tripped us up during QC — read before starting:

- **swww-daemon**: Arch ships `awww` (fork). The install script creates `/usr/local/bin/swww-daemon → awww-daemon` symlink. `pgrep swww-daemon` works after that.
- **OMP Zen prompt**: Looks like `~❯` — very minimal. That's correct, not broken.
- **cliphist**: Runs as `wl-paste --watch cliphist store`. `pgrep cliphist` returns nothing; use `pgrep -a wl-paste` instead.
- **notification-handler**: Is a library script, not executable standalone. Source it then call `notify_user`.
- **sidepad keybinds**: `SUPER+S` inits, `SUPER+CTRL+Right/Left` toggles. `CTRL+S` does nothing.
- **elephant-clipboard**: Must be installed for Walker clipboard mode (`yay -S elephant-clipboard`). Restart elephant service after install.
- **wallpaper-automation setting**: File is `wallpaper-automation.sh` (with `.sh`), not `wallpaper-automation`.
- **Screenshot keybinds**: `SUPER+PRINT` (menu), `SUPER+ALT+S` (instant area). Bare `Print` is unmapped.
- **matugen binary**: Installed to `/usr/bin/matugen` on Arch. If missing from PATH, scripts fail silently.
</content>
