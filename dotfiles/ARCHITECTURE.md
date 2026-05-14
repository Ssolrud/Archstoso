# ArchStoso Architecture Diagrams

Three diagrams covering the config source tree, color pipeline, and session startup.

---

## 1. Hyprland Config Source Tree

How `hyprland.conf` pulls in every module, and which variation presets are swappable.

```mermaid
graph TD
    HY["hyprland.conf\n(entry point)"]

    HY -->|source| CORE["conf/core.conf"]
    HY -->|source| ENV["conf/environment.conf"]
    HY -->|source| COL["colors.conf\n-- matugen generated --"]
    HY -->|source| AUTO["conf/autostart.conf"]
    HY -->|source| APP["conf/appearance.conf"]
    HY -->|source| KB["conf/keybindings.conf"]
    HY -->|source| WR["conf/windowrules.conf"]
    HY -->|source| CUST["conf/custom.conf\nuser overrides - edit freely"]

    CORE -->|source| NWG["monitors/nwg-displays.conf"]
    NWG -->|source| MONC["monitors.conf\nstub / nwg-displays generated"]
    NWG -->|source| WSC["workspaces.conf\nstub / nwg-displays generated"]
    CORE -->|source| LAY["layouts/default.conf\n[laptop] also available"]
    CORE -->|source| WSR["workspaces/default.conf"]

    ENV -->|source| ENVD["environments/default.conf\n[nvidia | kvm] also available"]

    APP -->|source| DEC["decorations/default.conf\n[blur | no-blur | rounding | gamemode ...]"]
    APP -->|source| WIN["windows/default.conf\n[border-1..4 | glass | transparent | gamemode ...]"]
    APP -->|source| ANIM["animations/default.conf\n[fast | smooth | dynamic | classic | disabled ...]"]

    KB  -->|source| KBD["keybindings/default.conf\n[fr] also available"]
    WR  -->|source| WRD["windowrules/default.conf"]

    LOCK["hyprlock.conf"] -->|source| COL

    style COL fill:#2d5,color:#fff
    style CUST fill:#e90,color:#fff
    style LOCK fill:#555,color:#fff
```

> To swap a variation: edit the `source =` line in `appearance.conf`, `environment.conf`, or
> `keybindings.conf` to point at a different preset file. The `custom.conf` file is never
> overwritten by installs — put monitor, keyboard, and scaling overrides there.

---

## 2. Matugen Color Pipeline

How a wallpaper change propagates new colors to every component.

```mermaid
graph LR
    WPF["wallpaper\n(any image)"]
    WPS["wallpaper.sh\nsources library.sh"]
    MAT["matugen\nconfig.toml"]

    WPF --> WPS
    WPS -->|matugen image ...| MAT

    MAT -->|template + hyprctl reload| HYPC["hypr/colors.conf"]
    MAT -->|template + pkill SIGUSR1| KITTYC["kitty/colors-matugen.conf"]
    MAT -->|template + waybar relaunch| WAYC["waybar/colors.css"]
    MAT -->|template| GTK3["gtk-3.0/colors.css"]
    MAT -->|template| GTK4["gtk-4.0/colors.css"]
    MAT -->|template + pkill USR2| BTOPC["btop/themes/matugen.theme"]
    MAT -->|template| SWAYNC["swaync/colors.css"]
    MAT -->|template| WLOGC["wlogout/colors.css"]
    MAT -->|template| WALKC["walker/colors.css"]

    HYPC --> HYPR["Hyprland\nhyprland.conf"]
    HYPC -->|source| LOCK["hyprlock.conf"]
    KITTYC -->|include| KITTY["Kitty terminal"]
    WAYC --> WAYBAR["Waybar"]
    GTK3 --> GTK3A["GTK3 apps"]
    GTK4 --> GTK4A["GTK4 apps"]
    BTOPC --> BTOP["btop"]
    SWAYNC --> NOTIF["SwayNC notifications"]
    WLOGC --> WLOG["wlogout power menu"]
    WALKC --> WALK["Walker launcher"]

    style MAT fill:#2d5,color:#fff
    style WPS fill:#2d5,color:#fff
```

> All nine components update atomically from the same wallpaper color seed.
> SwayNC, wlogout, and Walker each have their own `colors.css` from a shared template.

---

## 3. Session Startup Chain

What runs when Hyprland starts (exec-once entries in `autostart.conf`).

```mermaid
graph TD
    SESS["Hyprland session start"]
    AUTO["autostart.conf\nexec-once entries"]

    SESS --> AUTO

    AUTO --> LIST["listeners.sh --startall"]
    LIST --> GTKL["gtk-theme-switcher.sh\ndbus listener - syncs GTK theme on change"]
    LIST --> BATL["low-bat-notification.sh\nupower listener - fires low battery alert"]

    AUTO --> SWWW["swww-daemon\nawww wallpaper engine\n(symlinked: swww -> awww)"]

    AUTO --> WPR["wallpaper-restore.sh\nsleep 2 then waypaper --wallpaper"]
    WPR -->|uses| SWWW

    AUTO --> WBLAUNCH["waybar/launch.sh"]
    WBLAUNCH -->|reads| WBTHEME["settings/waybar-theme.sh\nstores: /modern;/modern/default"]
    WBTHEME -->|modern| WBMOD["themes/modern/\nconfig + style.css + colors.css"]
    WBTHEME -->|minimal| WBMIN["themes/minimal/\nconfig + style.css + colors.css"]

    AUTO --> SWAYNC["swaync\nnotification daemon"]
    AUTO --> GTK["hypr/scripts/gtk.sh\napplies GTK theme + icon theme"]
    AUTO --> HYPRIDLE["hypridle\nidle timeout -> hyprlock"]
    AUTO --> CLIP["wl-paste | cliphist store\nclipboard history daemon"]
    AUTO --> ASAUTO["archstoso-autostart\nuser-defined app autostart list"]
    AUTO --> CLEAN["hypr/scripts/cleanup.sh\nremoves stale lock files"]

    style SESS fill:#2d5bff,color:#fff
    style AUTO fill:#2d5bff,color:#fff
    style SWWW fill:#555,color:#fff
```

> `swww-daemon` must start **before** `wallpaper-restore.sh`. The `sleep 2` in
> `wallpaper-restore.sh` handles the race condition.
> The `swww` binary is a symlink to `awww` — the Arch `extra` repo ships the fork with
> renamed binaries.
