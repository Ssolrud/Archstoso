# Claude QC Guide — ArchStoso Dotfiles

This file tells Claude how to run the interactive QC from `QC.md` with a user on a fresh install.

## How to Run the QC

Work through `QC.md` section by section. For each section:
1. Tell the user which commands to run (paste them exactly)
2. Wait for their output
3. Diagnose failures — check scripts, configs, and services before guessing
4. Apply fixes to **both** the dotfiles repo AND the live `~/.config/` — always keep them in sync
5. Commit fixes at natural break points (end of each section or after 2–3 related fixes)

Keep responses short. The user is at a terminal — give them one section at a time, not the whole plan at once.

## Stack Reference

| Component | Binary | Config |
|-----------|--------|--------|
| WM | `hyprland` | `~/.config/hypr/` |
| Bar | `waybar` | `~/.config/waybar/` |
| Launcher | `walker` + `elephant` | `~/.config/walker/` |
| Colors | `matugen` | `~/.config/matugen/` |
| Notifications | `swaync` | `~/.config/swaync/` |
| Wallpaper | `awww` (symlinked as `swww`) + `waypaper` | `~/.config/waypaper/` |
| Terminal | `kitty` | `~/.config/kitty/` |
| Prompt | `oh-my-posh` (Zen theme) | `~/.config/ohmyposh/zen.toml` |
| Clipboard | `cliphist` via `wl-paste --watch` | — |
| Screen lock | `hyprlock` | `~/.config/hypr/hyprlock.conf` |
| Power menu | `wlogout` | `~/.config/wlogout/` |
| Arch ns | `~/.config/archstoso/` | scripts, settings, themes, listeners |

## Common Failure Patterns

### Nothing happens when pressing a keybind
1. Check `hyprctl getoption key` or grep the keybindings.conf
2. Run the bound command directly from terminal to see errors
3. Check Hyprland log: `cat /run/user/1000/hypr/*/hyprland.log | tail -30`

### Walker shows no apps
- `elephant listproviders` — if empty, providers missing
- Install: `yay -S elephant-desktopapplications elephant-websearch elephant-providerlist elephant-clipboard`
- Enable: `elephant service enable && systemctl --user start elephant.service`
- Note: use source variants, not `-bin` (they conflict with `elephant` source package)

### Walker clipboard (SUPER+V) shows no entries
- `elephant-clipboard` package must be installed (separate from other providers)
- After install, restart elephant: `systemctl --user restart elephant.service`

### swww-daemon not found
- Arch ships `awww` (fork with renamed binaries)
- Create symlinks: `sudo ln -sf /usr/bin/awww-daemon /usr/local/bin/swww-daemon && sudo ln -sf /usr/bin/awww /usr/local/bin/swww`
- The install script does this automatically

### Waybar colors not updating after matugen
- `~/.config/matugen/config.toml` must have `post_hook = '~/.config/waybar/launch.sh'` in `[templates.waybar]`

### SwayNC notifications have no background
- `~/.config/swaync/themes/modern/notifications.css` must have a rule for `.floating-notifications ... .notification` (not just `.notification.critical`)

### Screenshot not in clipboard after SUPER+ALT+S
- `screenshot.sh` instant modes must use `convert "$HOME/$NAME" png:- | wl-copy` after capturing
- `wl-copy --type image/jpeg` does NOT work — apps expect `image/png`

### Oh My Posh not showing
- The Zen theme displays as `~❯` — very minimal. If user sees directory + arrow, OMP IS working
- Check: `echo $PS1` in Kitty — should contain `_omp_get_primary`
- The init is in `~/.config/bashrc/20-customization`

### Notification handler does nothing when run directly
- `archstoso-notification-handler` is a **library** — it defines `notify_user()` but doesn't call it
- Correct test: `source ~/.config/archstoso/scripts/archstoso-notification-handler && notify_user --s "Test" --m "QC"`

### File manager (Thunar) opens but looks light
- Thunar is GTK3 — it follows `gtk-application-prefer-dark-theme` in `~/.config/gtk-3.0/settings.ini`
- Run `nwg-look` to configure GTK appearance
- Avoid KDE file managers (Dolphin) — they need `plasma-integration` for proper dark theme on non-Plasma

### Listeners kill fails with "not a pid" error
- Old `listeners.sh` used `kill "$pid"` where `$pid` can contain newlines
- Fix: use `pkill -f "$script_path"` instead — already fixed in current dotfiles

### Theme switcher does nothing
- `themes.sh` must use `fuzzel --dmenu`, not Walker (Walker mixes stdout/stderr)
- `theme.sh` files must write paths WITH leading slash: `/modern;/modern/default` not `modern;modern/default`

## Key File Locations

```
~/.config/archstoso/settings/     # All user-editable settings
~/.config/archstoso/scripts/      # System scripts
~/.config/archstoso/themes/       # Theme switcher scripts
~/.config/archstoso/listeners/    # Background watchers
~/.config/archstoso/bin/          # fzf utilities
~/.config/hypr/conf/              # Hyprland modular config
~/.config/hypr/scripts/           # Hyprland scripts
~/.cache/archstoso/hyprland-dotfiles/  # Runtime cache
```

## Dotfiles ↔ Live Config Sync

The dotfiles repo mirrors `~/.config/`. When fixing a file:
1. Edit the file in `dotfiles/`
2. Copy to live: `cp dotfiles/foo/bar.sh ~/.config/foo/bar.sh`
3. Test live
4. Commit the dotfiles change

Never edit only the live config — fixes must land in the repo.

## Sections That Are Always Optional

- **Section 19 (Game Mode)**: requires `gamemode` + `mangohud` — not in packages.txt by default
- **now-playing Waybar module**: commented out intentionally — no default media player assumed
- **battery listener**: only relevant on laptops — skip on desktop
- **Logout button in wlogout**: test last (ends the session)
</content>
