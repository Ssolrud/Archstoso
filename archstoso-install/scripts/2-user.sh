#!/usr/bin/env bash
# 2-user.sh — Chroot phase 2: AUR packages, dotfiles, user-level service setup.
#
# Called via:
#   arch-chroot /mnt /usr/bin/env -i \
#       HOME="/home/${USERNAME}" \
#       USER="${USERNAME}" \
#       LOGNAME="${USERNAME}" \
#       sudo -u "${USERNAME}" \
#       /root/archstoso-install/scripts/2-user.sh
#
# Runs as $USERNAME (not root). Has NOPASSWD sudo (granted by phase 1,
# revoked by phase 3). yay must never be called with sudo.

set -euo pipefail

# USER is set by the caller via env -i.
SCRIPT_DIR="/home/${USER}/archstoso-install"

# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"
# shellcheck source=configs/setup.conf
source "$SCRIPT_DIR/configs/setup.conf"

[[ "$(id -u)" -ne 0 ]] || die "2-user.sh must not run as root"

# ── Step functions ────────────────────────────────────────────────────────────

_step1_yay() {
    step 1 7 "Bootstrapping yay AUR helper"

    if command -v yay &>/dev/null; then
        info "yay already installed — skipping"
        return
    fi

    # yay-bin avoids a ~10-minute Go compilation on the live ISO.
    # The user can rebuild from source post-install if desired.
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd /
    rm -rf /tmp/yay-bin

    ok "yay installed"
}

_step2_aur_packages() {
    step 2 7 "Installing AUR packages"

    if [[ "$INSTALL_TYPE" != "HYPRLAND" ]]; then
        info "INSTALL_TYPE=${INSTALL_TYPE} — skipping AUR packages"
        return
    fi

    local pkg
    while IFS= read -r pkg; do
        # Strip inline comments and whitespace
        pkg="${pkg%%#*}"
        pkg="${pkg//[[:space:]]/}"
        [[ -z "$pkg" ]] && continue
        yay -S --needed --noconfirm "$pkg"
    done < "$SCRIPT_DIR/pkg-files/aur.txt"

    ok "AUR packages installed"
}

_step3_dotfiles() {
    step 3 7 "Deploying ArchStoso dotfiles"

    if [[ "$INSTALL_TYPE" != "HYPRLAND" || "$INSTALL_DOTFILES" != "yes" ]]; then
        info "Skipping dotfiles (INSTALL_TYPE=${INSTALL_TYPE}, INSTALL_DOTFILES=${INSTALL_DOTFILES})"
        return
    fi

    git clone --branch "$DOTFILES_BRANCH" \
        https://github.com/Ssolrud/ArchStoso \
        /tmp/archstoso-dotfiles

    # ARCHSTOSO_UNATTENDED suppresses interactive prompts in install.sh.
    # Support for this env var must be added to dotfiles/install.sh.
    ARCHSTOSO_UNATTENDED=1 bash /tmp/archstoso-dotfiles/dotfiles/install.sh

    rm -rf /tmp/archstoso-dotfiles
    ok "Dotfiles deployed"
}

_step4_custom_conf() {
    step 4 7 "Writing Hyprland custom.conf overrides"

    if [[ "$INSTALL_TYPE" != "HYPRLAND" || "$INSTALL_DOTFILES" != "yes" ]]; then
        info "Skipping custom.conf (dotfiles not deployed)"
        return
    fi

    local custom_conf="$HOME/.config/hypr/conf/custom.conf"
    if [[ ! -f "$custom_conf" ]]; then
        mkdir -p "$(dirname "$custom_conf")"
        touch "$custom_conf"
    fi

    # Write kb_layout only if not already present (install.sh may have seeded the file).
    if ! grep -q 'kb_layout' "$custom_conf"; then
        cat >> "$custom_conf" <<EOF

# Written by ArchStoso installer
input {
    kb_layout = ${KEYMAP}
}
monitor = ,preferred,auto,1.0
EOF
        ok "custom.conf: kb_layout=${KEYMAP}, monitor fallback written"
    else
        info "custom.conf: kb_layout already present — not overwriting"
    fi
}

_step5_elephant_service() {
    step 5 7 "Enabling elephant data daemon"

    if [[ "$INSTALL_TYPE" != "HYPRLAND" ]]; then
        info "INSTALL_TYPE=${INSTALL_TYPE} — skipping elephant service"
        return
    fi

    local unit_src="/usr/lib/systemd/user/elephant.service"
    if [[ ! -f "$unit_src" ]]; then
        warn "elephant.service unit not found — skipping (elephant may not be installed)"
        return
    fi

    # loginctl enable-linger lets the user's systemd instance start at boot
    # without an interactive login session.
    sudo loginctl enable-linger "$USERNAME"

    # systemctl --user cannot run in a chroot (no active D-Bus/user session).
    # Write the enable symlink directly instead.
    local wants_dir="$HOME/.config/systemd/user/default.target.wants"
    mkdir -p "$wants_dir"
    ln -sf "$unit_src" "$wants_dir/elephant.service"

    ok "elephant.service: linger enabled, unit symlinked for autostart"
}

_step6_default_browser() {
    step 6 7 "Setting default browser MIME associations"

    if [[ "$INSTALL_TYPE" != "HYPRLAND" ]]; then
        info "INSTALL_TYPE=${INSTALL_TYPE} — skipping MIME associations"
        return
    fi

    # xdg-settings requires a running D-Bus session; write mimeapps.list directly.
    local mimeapps="$HOME/.config/mimeapps.list"
    mkdir -p "$(dirname "$mimeapps")"
    if [[ ! -f "$mimeapps" ]]; then
        printf '[Default Applications]\n' > "$mimeapps"
    fi

    local mime
    for mime in x-scheme-handler/http x-scheme-handler/https text/html; do
        if ! grep -q "^${mime}=" "$mimeapps" 2>/dev/null; then
            printf '%s=brave-browser.desktop\n' "$mime" >> "$mimeapps"
        fi
    done

    ok "mimeapps.list: brave-browser.desktop set for http/https/html"
}

_step7_xdg_dirs() {
    step 7 7 "Creating XDG user directories"
    xdg-user-dirs-update
    ok "XDG user directories created"
}

# ── Orchestrator ──────────────────────────────────────────────────────────────

run_user_setup() {
    section "Chroot Phase 2: AUR Packages, Dotfiles, User Services"

    _step1_yay
    _step2_aur_packages
    _step3_dotfiles
    _step4_custom_conf
    _step5_elephant_service
    _step6_default_browser
    _step7_xdg_dirs

    echo
    ok "Phase 2 complete — AUR packages installed, user environment configured"
}

run_user_setup
