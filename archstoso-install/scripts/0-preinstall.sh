#!/usr/bin/env bash
# 0-preinstall.sh — Pre-chroot setup: keyring, mirrors, pacstrap, fstab, zram.
# Expects /mnt to be already partitioned, formatted, and mounted by lib/disk.sh.

set -euo pipefail

# Resolve to the installer root (parent of scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"
# shellcheck source=configs/setup.conf
source "$SCRIPT_DIR/configs/setup.conf"

# ── Sanity guard ──────────────────────────────────────────────────────────────
# Abort early if /mnt is not a mount point — disk.sh must have run first.
if ! mountpoint -q /mnt; then
    die "/mnt is not mounted. Run lib/disk.sh before this script."
fi

# ── Step functions ────────────────────────────────────────────────────────────

_step1_sync_clock() {
    step 1 9 "Syncing system clock via NTP"
    timedatectl set-ntp true
    ok "NTP sync enabled"
}

_step2_update_keyring() {
    step 2 9 "Refreshing Arch Linux keyring"
    # A stale ISO keyring causes package signature verification failures during
    # pacstrap. Updating it here avoids the most common fresh-ISO failure mode.
    pacman -Sy --noconfirm --needed archlinux-keyring
    ok "Keyring updated"
}

_step3_parallel_downloads() {
    step 3 9 "Enabling parallel downloads in pacman"
    sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
    ok "Parallel downloads enabled"
}

_step4_mirrors() {
    step 4 9 "Selecting fastest mirrors with reflector"
    pacman -S --noconfirm --needed reflector rsync

    # Attempt GeoIP country detection for a tighter regional filter.
    local iso
    iso=$(curl -s --max-time 10 https://ipapi.co/country/ 2>/dev/null || true)

    if [[ -n "$iso" ]]; then
        info "Country: ${iso} — filtering mirrors by country"
        reflector -a 48 -c "$iso" -f 5 -l 20 --sort rate \
            --save /etc/pacman.d/mirrorlist
    else
        info "Country: unknown — using global mirrors"
        reflector -a 48 -f 5 -l 20 --sort rate \
            --save /etc/pacman.d/mirrorlist
    fi
    ok "Mirror list updated"
}

_step5_microcode() {
    step 5 9 "Detecting CPU vendor for microcode"
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        MICROCODE_PKG="intel-ucode"
        info "Intel CPU detected — will install intel-ucode"
    elif grep -q "AuthenticAMD" /proc/cpuinfo; then
        MICROCODE_PKG="amd-ucode"
        info "AMD CPU detected — will install amd-ucode"
    else
        MICROCODE_PKG=""
        warn "CPU vendor unrecognised — no microcode package will be installed"
    fi
    ok "Microcode: ${MICROCODE_PKG:-none}"
}

_step6_pacstrap() {
    step 6 9 "Installing base system with pacstrap"

    local -a PACSTRAP_PKGS=(
        base base-devel
        linux linux-firmware linux-headers
        networkmanager
        sudo git curl wget
        systemd-zram-generator   # zram swap (configured in step 8)
    )

    [[ -n "${MICROCODE_PKG:-}" ]] && PACSTRAP_PKGS+=("$MICROCODE_PKG")

    info "Packages: ${PACSTRAP_PKGS[*]}"
    pacstrap -K /mnt "${PACSTRAP_PKGS[@]}"
    ok "Base system installed"
}

_step7_fstab() {
    step 7 9 "Generating fstab"
    genfstab -U /mnt >> /mnt/etc/fstab
    ok "fstab written to /mnt/etc/fstab"
    info "Contents:"
    sed 's/^/    /' /mnt/etc/fstab
}

_step8_zram() {
    step 8 9 "Configuring zram swap"
    # systemd-zram-generator reads this file at first boot and creates /dev/zram0.
    # The expression "ram / 2" is evaluated by the generator — it is not shell math.
    # zstd gives better compression than lz4 at comparable speed on modern CPUs.
    cat > /mnt/etc/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF
    ok "zram-generator.conf written (zram0: ram/2, zstd)"
}

_step9_copy_mirrorlist() {
    step 9 9 "Copying mirrorlist into new root"
    cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
    ok "Mirrorlist copied to /mnt/etc/pacman.d/mirrorlist"
}

# ── Orchestrator ──────────────────────────────────────────────────────────────

run_preinstall() {
    section "Pre-Install: Keyring, Mirrors, pacstrap, fstab, zram"

    _step1_sync_clock
    _step2_update_keyring
    _step3_parallel_downloads
    _step4_mirrors
    _step5_microcode
    _step6_pacstrap
    _step7_fstab
    _step8_zram
    _step9_copy_mirrorlist

    echo
    ok "Pre-install complete — /mnt is ready for arch-chroot"
}

run_preinstall
