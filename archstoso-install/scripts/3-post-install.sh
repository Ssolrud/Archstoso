#!/usr/bin/env bash
# 3-post-install.sh — Chroot phase 3: bootloader, display manager, services, sudoers lockdown.
#
# Called via:
#   arch-chroot /mnt /root/archstoso-install/scripts/3-post-install.sh
#
# All values come from setup.conf — no interactive prompts.
# Must run as root. Runs after 1-setup.sh and 2-user.sh are complete.

set -euo pipefail

# Hardcoded: this is always the installer path inside the chroot.
SCRIPT_DIR=/root/archstoso-install

# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"
# shellcheck source=configs/setup.conf
source "$SCRIPT_DIR/configs/setup.conf"

# ── Step functions ────────────────────────────────────────────────────────────

_step1_bootctl_install() {
    step 1 9 "Installing systemd-boot EFI binary"
    bootctl install
    ok "systemd-boot installed to /boot/EFI/"
}

_step2_loader_conf() {
    step 2 9 "Writing /boot/loader/loader.conf"
    mkdir -p /boot/loader
    cat > /boot/loader/loader.conf <<'EOF'
default  archstoso.conf
timeout  5
console-mode auto
editor   no
EOF
    # editor no: prevents an attacker with physical access from editing kernel
    # parameters at the boot prompt (e.g., adding init=/bin/sh).
    ok "loader.conf written"
}

_step3_boot_entry() {
    step 3 9 "Writing /boot/loader/entries/archstoso.conf"
    mkdir -p /boot/loader/entries

    # ── Microcode ─────────────────────────────────────────────────────────────
    local microcode_line=""
    if [[ -f /boot/intel-ucode.img ]]; then
        microcode_line="initrd  /intel-ucode.img"
    elif [[ -f /boot/amd-ucode.img ]]; then
        microcode_line="initrd  /amd-ucode.img"
    fi

    # ── Root options (LUKS vs plain, ext4 vs btrfs) ───────────────────────────
    local root_options
    if [[ "$LUKS" == "yes" ]]; then
        root_options="cryptdevice=UUID=${LUKS_UUID}:archroot root=/dev/mapper/archroot"
        if [[ "$FS_TYPE" == "btrfs" ]]; then
            root_options="${root_options} rootflags=subvol=@"
        fi
    else
        root_options="root=UUID=${ROOT_UUID}"
        if [[ "$FS_TYPE" == "btrfs" ]]; then
            root_options="${root_options} rootflags=subvol=@"
        fi
    fi

    # ── NVIDIA DRM kernel parameter ───────────────────────────────────────────
    # Required for Wayland compositors (Hyprland) to use NVIDIA as primary output.
    local nvidia_opts=""
    local lspci_out
    lspci_out=$(lspci 2>/dev/null || true)
    if echo "$lspci_out" | grep -qE "NVIDIA|GeForce"; then
        nvidia_opts=" nvidia-drm.modeset=1"
    fi

    # ── Assemble the entry ────────────────────────────────────────────────────
    local entry_content
    entry_content="title   ArchStoso Linux
linux   /vmlinuz-linux
${microcode_line:+${microcode_line}$'\n'}initrd  /initramfs-linux.img
options ${root_options} rw quiet${nvidia_opts}"

    printf '%s\n' "$entry_content" > /boot/loader/entries/archstoso.conf

    # Print what was written so the install log captures the exact entry.
    info "Boot entry written:"
    while IFS= read -r line; do
        info "  ${line}"
    done < /boot/loader/entries/archstoso.conf

    ok "Boot entry written to /boot/loader/entries/archstoso.conf"
}

_step4_bootctl_hook() {
    step 4 9 "Installing pacman hook: auto-update systemd-boot on systemd upgrades"
    mkdir -p /etc/pacman.d/hooks
    cat > /etc/pacman.d/hooks/95-systemd-boot.hook <<'EOF'
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF
    # Without this hook, upgrading systemd would update the package's EFI binary
    # in /usr/lib but leave the stale copy in /boot/EFI/ — causing a boot mismatch.
    ok "95-systemd-boot.hook written"
}

_step5_sddm() {
    step 5 9 "Configuring SDDM display manager"

    if [[ "$INSTALL_TYPE" != "HYPRLAND" ]]; then
        info "INSTALL_TYPE=${INSTALL_TYPE} — skipping SDDM"
        return
    fi

    systemctl enable sddm.service

    # Install the bundled ArchStoso SDDM theme
    local theme_src="$SCRIPT_DIR/assets/sddm-theme"
    local theme_dst="/usr/share/sddm/themes/archstoso"
    if [[ -d "$theme_src" ]]; then
        mkdir -p "$theme_dst/assets"
        cp -r "$theme_src"/. "$theme_dst/"
        # Copy the bundled logo (travels with the installer tree)
        local logo_src="$SCRIPT_DIR/assets/sddm-theme/assets/archstoso.svg"
        if [[ -f "$logo_src" ]]; then
            cp "$logo_src" "$theme_dst/assets/archstoso.svg"
            ok "SDDM theme: archstoso.svg logo installed"
        else
            warn "SDDM theme: logo not found at ${logo_src} — theme will display without logo"
        fi
        ok "SDDM theme installed to ${theme_dst}"
    else
        warn "SDDM theme source not found at ${theme_src} — using default SDDM theme"
    fi

    mkdir -p /etc/sddm.conf.d
    cat > /etc/sddm.conf.d/archstoso.conf <<'EOF'
[Theme]
Current=archstoso

[Autologin]
Relogin=false

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
Numlock=on
EOF

    # Wayland session file — many packages ship this, but add a fallback so
    # SDDM can list Hyprland even if the package hasn't installed it yet.
    local session_file=/usr/share/wayland-sessions/hyprland.desktop
    if [[ ! -f "$session_file" ]]; then
        mkdir -p /usr/share/wayland-sessions
        cat > "$session_file" <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=uwsm start hyprland-uwsm.desktop
Type=Application
EOF
        ok "Fallback hyprland.desktop written to /usr/share/wayland-sessions/"
    else
        info "hyprland.desktop already present — not overwriting"
    fi

    ok "sddm.service enabled; /etc/sddm.conf.d/archstoso.conf written"
}

_step6_services() {
    step 6 9 "Enabling system services"

    # Unconditional: these make sense on any desktop system.
    systemctl enable bluetooth.service
    systemctl enable cups.service
    systemctl enable cups.socket
    systemctl enable avahi-daemon.service
    systemctl enable systemd-timesyncd.service
    ok "bluetooth, cups, avahi-daemon, systemd-timesyncd enabled"

    # fstrim: only beneficial on SSDs; spinning disks have no TRIM command.
    local disk_basename
    disk_basename=$(basename "$DISK")
    local rotational
    rotational=$(cat "/sys/block/${disk_basename}/queue/rotational" 2>/dev/null || echo "1")
    if [[ "$rotational" == "0" ]]; then
        systemctl enable fstrim.timer
        ok "fstrim.timer enabled (SSD detected: rotational=0)"
    else
        info "fstrim.timer skipped (rotational=${rotational})"
    fi

    # paccache.timer: automatic pacman cache pruning (from pacman-contrib).
    if [[ -f /usr/lib/systemd/system/paccache.timer ]]; then
        systemctl enable paccache.timer
        ok "paccache.timer enabled"
    else
        info "paccache.timer not found — skipping (pacman-contrib may not be installed)"
    fi
}

_step7_sudoers_lockdown() {
    step 7 9 "Revoking NOPASSWD sudo — locking down wheel group"

    # Phase 1 granted NOPASSWD to let yay run in phase 2 without a password
    # prompt inside the chroot. Now that AUR installs are done, enforce normal
    # password-required sudo for the wheel group.
    sed -i \
        's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' \
        /etc/sudoers
    sed -i \
        's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' \
        /etc/sudoers
    sed -i \
        's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' \
        /etc/sudoers

    # A broken sudoers file locks every wheel user out of sudo permanently.
    # visudo -c validates the syntax before we move on.
    if ! visudo -c; then
        die "sudoers validation failed — /etc/sudoers may be corrupt. Fix manually before rebooting."
    fi

    ok "Wheel group: NOPASSWD revoked; password-required sudo enabled; sudoers validated"
}

_step8_copy_log() {
    step 8 9 "Copying install log to /home/${USERNAME}/"

    if [[ -f /tmp/archstoso-install.log ]]; then
        cp /tmp/archstoso-install.log "/home/${USERNAME}/archstoso-install.log"
        chown "${USERNAME}:${USERNAME}" "/home/${USERNAME}/archstoso-install.log"
        ok "Install log copied to /home/${USERNAME}/archstoso-install.log"
    else
        info "No install log found at /tmp/archstoso-install.log — skipping"
    fi
}

_step9_cleanup() {
    step 9 9 "Cleaning up installer files"
    rm -rf /root/archstoso-install
    rm -rf "/home/${USERNAME}/archstoso-install"
    ok "Installer removed from /root/ and /home/${USERNAME}/"
}

# ── Orchestrator ──────────────────────────────────────────────────────────────

run_post_install() {
    section "Chroot Phase 3: Bootloader, Services, Sudoers Lockdown"

    _step1_bootctl_install
    _step2_loader_conf
    _step3_boot_entry
    _step4_bootctl_hook
    _step5_sddm
    _step6_services
    _step7_sudoers_lockdown
    _step8_copy_log
    _step9_cleanup

    echo
    ok "Phase 3 complete — system is ready to reboot"
    info "Remove the installation medium and run: reboot"
}

run_post_install
