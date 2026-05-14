#!/usr/bin/env bash
# 1-setup.sh — Chroot phase 1: system configuration, package installation, user setup.
# Called via: arch-chroot /mnt /root/archstoso-install/scripts/1-setup.sh
# All values come from setup.conf — no interactive prompts.

set -euo pipefail

# Hardcoded: this is always the installer path inside the chroot.
SCRIPT_DIR=/root/archstoso-install

# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"
# shellcheck source=configs/setup.conf
source "$SCRIPT_DIR/configs/setup.conf"

# ── Step functions ────────────────────────────────────────────────────────────

_step1_timezone() {
    step 1 15 "Setting timezone: ${TIMEZONE}"
    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    hwclock --systohc
    ok "Timezone set to ${TIMEZONE}, hardware clock synced"
}

_step2_locale() {
    step 2 15 "Generating locales"

    # Handle both '#en_US.UTF-8 UTF-8' and '# en_US.UTF-8 UTF-8' (space after #)
    local escaped_locale
    escaped_locale=$(printf '%s\n' "$LOCALE" | sed 's/[.]/[.]/g')
    sed -i "s|^#[[:space:]]*${escaped_locale}|${LOCALE}|" /etc/locale.gen

    # Norwegian locale is always enabled — needed by nb_NO LC_TIME, man pages, etc.
    sed -i 's/^#[[:space:]]*nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/' /etc/locale.gen

    locale-gen

    cat > /etc/locale.conf <<EOF
LANG=en_US.UTF-8
LC_TIME=en_US.UTF-8
EOF
    ok "Locales generated; LANG=en_US.UTF-8"
}

_step3_vconsole() {
    step 3 15 "Setting console keymap: ${KEYMAP}"
    printf 'KEYMAP=%s\n' "$KEYMAP" > /etc/vconsole.conf
    ok "vconsole.conf written"
}

_step4_hostname() {
    step 4 15 "Configuring hostname: ${HOSTNAME}"
    printf '%s\n' "$HOSTNAME" > /etc/hostname
    cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain   ${HOSTNAME}
EOF
    ok "Hostname and /etc/hosts written"
}

_step5_mkinitcpio() {
    step 5 15 "Configuring mkinitcpio"

    # ── GPU detection ─────────────────────────────────────────────────────────
    local lspci_out
    lspci_out=$(lspci 2>/dev/null || true)

    local has_nvidia=false has_intel=false
    if echo "$lspci_out" | grep -qE "NVIDIA|GeForce"; then
        has_nvidia=true
    fi
    if echo "$lspci_out" | grep -qE "Intel.*UHD|Intel.*HD Graphics|Intel.*Iris"; then
        has_intel=true
    fi

    # ── MODULES ───────────────────────────────────────────────────────────────
    local gpu_modules=""
    if [[ "$has_nvidia" == true ]]; then
        gpu_modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
    fi
    # Intel (amdgpu) autoloads — no explicit module needed in MODULES array

    # Replace the MODULES=(...) content. Works whether it is currently empty or
    # already populated.
    if [[ -n "$gpu_modules" ]]; then
        sed -i "s|^MODULES=(.*)|MODULES=(${gpu_modules})|" /etc/mkinitcpio.conf
    fi

    # ── HOOKS ─────────────────────────────────────────────────────────────────
    if [[ "$LUKS" == "yes" ]]; then
        # Insert 'encrypt' immediately before 'filesystems' in the HOOKS line.
        # This is idempotent — if 'encrypt' is already present the regex won't match.
        sed -i 's/\(HOOKS=.*\)\(filesystems\)/\1encrypt \2/' /etc/mkinitcpio.conf
    fi

    # ── zstd compression ──────────────────────────────────────────────────────
    # zstd gives the best speed/ratio tradeoff; the default (xz) is much slower.
    sed -i 's/^#COMPRESSION="zstd"/COMPRESSION="zstd"/' /etc/mkinitcpio.conf

    # ── Diagnostic output ─────────────────────────────────────────────────────
    local hooks_line modules_line
    hooks_line=$(grep '^HOOKS=' /etc/mkinitcpio.conf)
    modules_line=$(grep '^MODULES=' /etc/mkinitcpio.conf)
    info "MODULES : ${modules_line}"
    info "HOOKS   : ${hooks_line}"

    mkinitcpio -P
    ok "initramfs rebuilt"
}

_step6_makepkg() {
    step 6 15 "Tuning makepkg (parallel builds)"
    local cores
    cores=$(nproc)
    sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j${cores}\"/" /etc/makepkg.conf
    sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T ${cores} -z -)/" /etc/makepkg.conf
    ok "makepkg: -j${cores} build parallelism, xz -T${cores}"
}

_step7_pacman_config() {
    step 7 15 "Enabling parallel downloads and multilib in pacman"
    sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

    # Uncomment the [multilib] section header and its Include line.
    # Required for lib32 packages, NVIDIA lib32, Steam, Wine.
    sed -i '/\[multilib\]/,/Include/{s/^#//}' /etc/pacman.conf

    pacman -Sy --noconfirm
    ok "pacman.conf updated; database refreshed"
}

_install_pkg_list() {
    # Usage: _install_pkg_list /path/to/pkg-file.txt
    local pkg_file="$1"
    local pkg
    while IFS= read -r pkg; do
        # Strip comments and whitespace
        pkg="${pkg%%#*}"
        pkg="${pkg//[[:space:]]/}"
        [[ -z "$pkg" ]] && continue
        pacman -S --needed --noconfirm "$pkg"
    done < "$pkg_file"
}

_step8_base_packages() {
    step 8 15 "Installing base packages"
    _install_pkg_list "$SCRIPT_DIR/pkg-files/base.txt"
    ok "Base packages installed"
}

_step9_hyprland_packages() {
    step 9 15 "Installing Hyprland packages"
    if [[ "$INSTALL_TYPE" != "HYPRLAND" ]]; then
        info "INSTALL_TYPE=${INSTALL_TYPE} — skipping Hyprland packages"
        return
    fi
    _install_pkg_list "$SCRIPT_DIR/pkg-files/hyprland.txt"
    ok "Hyprland packages installed"
}

_step10_gpu_drivers() {
    step 10 15 "Detecting GPU and installing drivers"

    local lspci_out
    lspci_out=$(lspci 2>/dev/null || true)

    local has_nvidia=false has_intel=false has_amd=false

    if echo "$lspci_out" | grep -qE "NVIDIA|GeForce"; then
        has_nvidia=true
    fi
    if echo "$lspci_out" | grep -qE "Intel.*UHD|Intel.*HD Graphics|Intel.*Iris"; then
        has_intel=true
    fi
    if echo "$lspci_out" | grep -qE "Radeon|AMD.*VGA"; then
        has_amd=true
    fi

    if [[ "$has_nvidia" == true && "$has_intel" == true ]]; then
        info "Optimus hybrid GPU detected — installing both Intel and NVIDIA drivers"
    fi

    local any_gpu=false

    if [[ "$has_nvidia" == true ]]; then
        any_gpu=true
        info "NVIDIA GPU detected"
        pacman -S --needed --noconfirm \
            nvidia nvidia-utils nvidia-prime lib32-nvidia-utils

        # Enable DRM kernel mode-setting for Wayland compositors.
        # fbdev=1 provides a framebuffer fallback for TTY on Wayland.
        cat > /etc/modprobe.d/nvidia.conf <<'EOF'
options nvidia-drm modeset=1 fbdev=1
EOF

        # Pacman hook to rebuild initramfs when nvidia or linux is updated.
        # The Exec logic skips rebuild if the trigger was 'linux*' — mkinitcpio
        # already runs from the linux package's own install hook in that case.
        mkdir -p /etc/pacman.d/hooks
        cat > /etc/pacman.d/hooks/nvidia.hook <<'EOF'
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update NVIDIA module in initramfs
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF
        ok "NVIDIA: drivers installed, modprobe.d and pacman hook written"
    fi

    if [[ "$has_intel" == true ]]; then
        any_gpu=true
        info "Intel GPU detected"
        # vulkan-intel: Vulkan ICD for Intel (Xe/Gen9+)
        # intel-media-driver: VAAPI for Gen9.5+ (Broadwell+, aka iHD driver)
        # libva-intel-driver: VAAPI for older Gen (i965 driver, kept for compat)
        # lib32-mesa: 32-bit OpenGL/Vulkan for Steam, Wine
        pacman -S --needed --noconfirm \
            mesa vulkan-intel intel-media-driver libva-intel-driver lib32-mesa
        ok "Intel: drivers installed"
    fi

    if [[ "$has_amd" == true ]]; then
        any_gpu=true
        info "AMD GPU detected"
        pacman -S --needed --noconfirm \
            mesa xf86-video-amdgpu vulkan-radeon lib32-mesa libva-mesa-driver
        ok "AMD: drivers installed"
    fi

    if [[ "$any_gpu" == false ]]; then
        warn "No recognised GPU found — skipping GPU driver install"
    fi
}

_step11_create_user() {
    step 11 15 "Creating user: ${USERNAME}"
    groupadd -f libvirt
    useradd -m -G wheel,audio,video,storage,optical,input,libvirt \
        -s /bin/bash "$USERNAME"
    printf '%s:%s\n' "$USERNAME" "$USER_PASSWORD" | chpasswd
    printf '%s:%s\n' "root"     "$ROOT_PASSWORD"  | chpasswd
    ok "User ${USERNAME} created; root password set"
}

_step12_sudoers() {
    step 12 15 "Granting wheel NOPASSWD sudo (temporary — revoked in phase 3)"
    # AUR helpers must run makepkg as a non-root user with passwordless sudo
    # during phase 2. Phase 3 tightens this back to password-required.
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' \
        /etc/sudoers
    ok "Wheel group: NOPASSWD sudo enabled"
}

_step13_networkmanager() {
    step 13 15 "Enabling NetworkManager"
    systemctl enable NetworkManager.service
    ok "NetworkManager enabled"
}

_step14_awww_symlinks() {
    step 14 15 "Creating swww → awww compatibility symlinks"

    if [[ "$INSTALL_TYPE" != "HYPRLAND" ]]; then
        info "INSTALL_TYPE=${INSTALL_TYPE} — skipping awww symlinks"
        return
    fi

    # The Arch extra repo ships 'awww' (fork of swww) with renamed binaries.
    # Our dotfiles scripts still call 'swww' and 'swww-daemon', so we shim them.
    if ! command -v awww &>/dev/null; then
        warn "awww not found in PATH — skipping symlinks (awww may not be installed)"
        return
    fi

    ln -sf /usr/bin/awww        /usr/local/bin/swww
    ln -sf /usr/bin/awww-daemon /usr/local/bin/swww-daemon
    ok "Symlinks: /usr/local/bin/swww → awww, /usr/local/bin/swww-daemon → awww-daemon"
}

_step15_copy_installer() {
    step 15 15 "Copying installer to /home/${USERNAME}/ for phase 2"
    # Phase 2 runs as $USERNAME, who cannot read /root/.
    # The copy must happen now, while we are still root inside the chroot.
    cp -r /root/archstoso-install "/home/${USERNAME}/archstoso-install"
    chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/archstoso-install"
    ok "Installer copied to /home/${USERNAME}/archstoso-install"
}

# ── Orchestrator ──────────────────────────────────────────────────────────────

run_setup() {
    section "Chroot Phase 1: System Configuration"

    _step1_timezone
    _step2_locale
    _step3_vconsole
    _step4_hostname
    _step5_mkinitcpio
    _step6_makepkg
    _step7_pacman_config
    _step8_base_packages
    _step9_hyprland_packages
    _step10_gpu_drivers
    _step11_create_user
    _step12_sudoers
    _step13_networkmanager
    _step14_awww_symlinks
    _step15_copy_installer

    echo
    ok "Phase 1 complete — system configured, user created, ready for phase 2"
}

run_setup
