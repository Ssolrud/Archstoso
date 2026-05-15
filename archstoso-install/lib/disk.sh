#!/usr/bin/env bash
# lib/disk.sh — Disk setup: partition, LUKS2, format, btrfs subvolumes, mount.
# Sourced by archstoso.sh. Requires ui.sh and validate.sh already sourced.
# Expects these variables set from setup.conf before any function is called:
#   DISK, FS_TYPE, LUKS, LUKS_PASSWORD (only when LUKS=yes)

# ── Force-unmount everything on the target disk ───────────────────────────────
# Live ISOs auto-mount partitions via udev/udisks. We must clear them before
# sgdisk or mkfs can write to the disk.
_unmount_disk() {
    local disk="$1"

    # Unmount /mnt tree first (previous failed attempt may have left it mounted)
    umount -R /mnt 2>/dev/null || true

    # Deactivate any swap on this disk
    swapoff -a 2>/dev/null || true

    # Close any LUKS containers whose backing device is on this disk
    while IFS= read -r name; do
        local backing
        backing=$(cryptsetup status "$name" 2>/dev/null | awk '/device:/{print $2}') || true
        if [[ "$backing" == "${disk}"* ]]; then
            cryptsetup close "$name" 2>/dev/null || true
        fi
    done < <(dmsetup ls 2>/dev/null | awk '{print $1}')

    # Unmount every partition on the disk
    while IFS= read -r part; do
        [[ "$part" == "$disk" ]] && continue
        umount -R "$part" 2>/dev/null || true
    done < <(lsblk -lnpo NAME "$disk" 2>/dev/null)
}

# ── Partition the disk ─────────────────────────────────────────────────────────
partition_disk() {
    info "Unmounting any existing filesystems on ${DISK}..."
    _unmount_disk "$DISK"

    info "Wiping all partition data on ${DISK}..."
    sgdisk -Z "$DISK"

    info "Creating fresh GPT on ${DISK}..."
    sgdisk -o "$DISK"

    info "Creating EFI partition (1G) and root partition (remainder)..."
    sgdisk -n 1:0:+1G   -t 1:ef00 -c 1:EFIBOOT "$DISK"
    sgdisk -n 2:0:0      -t 2:8300 -c 2:ARCHROOT "$DISK"

    # partprobe asks the kernel to re-read the partition table. sleep 2 gives
    # udev time to create the new /dev nodes before we reference them.
    partprobe "$DISK"
    sleep 2

    # NVMe devices name partitions with a 'p' separator (nvme0n1p1, nvme0n1p2).
    # All other block devices (sda, vda, mmcblk0, etc.) append the digit directly,
    # except mmcblk which also uses 'p' — handle that the same way as NVMe.
    if [[ "$DISK" =~ nvme[0-9]|mmcblk[0-9] ]]; then
        PART_EFI="${DISK}p1"
        PART_ROOT="${DISK}p2"
    else
        PART_EFI="${DISK}1"
        PART_ROOT="${DISK}2"
    fi

    export PART_EFI PART_ROOT
    ok "Partitioned: EFI=${PART_EFI}  ROOT=${PART_ROOT}"
}

# ── Set up LUKS2 encryption on the root partition ─────────────────────────────
setup_luks() {
    info "Formatting ${PART_ROOT} with LUKS2 (argon2id)..."
    # argon2id is the memory-hard KDF recommended by OWASP; more resistant to
    # GPU/ASIC brute-force than the default pbkdf2.
    echo -n "$LUKS_PASSWORD" \
        | cryptsetup luksFormat \
            --type luks2 \
            --pbkdf argon2id \
            --batch-mode \
            "$PART_ROOT" -

    info "Opening LUKS container as /dev/mapper/archroot..."
    echo -n "$LUKS_PASSWORD" \
        | cryptsetup open "$PART_ROOT" archroot -

    # Save the UUID now while PART_ROOT still refers to the raw ciphertext device.
    # The bootloader (mkinitcpio + kernel cmdline) needs this UUID to unlock on boot.
    LUKS_UUID=$(blkid -s UUID -o value "$PART_ROOT")
    ROOT_DEVICE="/dev/mapper/archroot"

    export LUKS_UUID ROOT_DEVICE
    ok "LUKS2 open: ROOT_DEVICE=${ROOT_DEVICE}  UUID=${LUKS_UUID}"
}

# ── Format partitions ─────────────────────────────────────────────────────────
format_partitions() {
    info "Formatting EFI partition ${PART_EFI} as FAT32..."
    mkfs.fat -F32 -n EFIBOOT "$PART_EFI"

    case "$FS_TYPE" in
        btrfs)
            info "Formatting ${ROOT_DEVICE} as btrfs..."
            mkfs.btrfs -f -L archroot "$ROOT_DEVICE"
            ;;
        ext4)
            info "Formatting ${ROOT_DEVICE} as ext4..."
            mkfs.ext4 -F -L archroot "$ROOT_DEVICE"
            ;;
        *)
            die "Unknown FS_TYPE '${FS_TYPE}'. Expected 'btrfs' or 'ext4'."
            ;;
    esac

    ok "Partitions formatted"
}

# ── Create btrfs subvolumes ────────────────────────────────────────────────────
create_btrfs_subvolumes() {
    info "Mounting ${ROOT_DEVICE} temporarily to create btrfs subvolumes..."
    mount "$ROOT_DEVICE" /mnt

    info "Creating subvolumes: @ @home @log @pkg @snapshots..."
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@log
    btrfs subvolume create /mnt/@pkg
    btrfs subvolume create /mnt/@snapshots

    # Must unmount the top-level volume before mounting individual subvolumes
    # in mount_filesystems; mounting atop an already-mounted btrfs volume would
    # nest incorrectly and produce wrong /mnt/home, /mnt/var/log bind points.
    umount /mnt
    ok "Btrfs subvolumes created"
}

# ── Mount filesystems ─────────────────────────────────────────────────────────
mount_filesystems() {
    local drive_type
    drive_type=$(detect_drive_type "$DISK")

    local btrfs_opts_base="noatime,compress=zstd:1,commit=120,space_cache=v2"
    local btrfs_opts
    if [[ "$drive_type" == "ssd" ]]; then
        # 'ssd' enables SSD-aware allocation heuristics inside btrfs; omit on HDD.
        btrfs_opts="${btrfs_opts_base},ssd"
    else
        btrfs_opts="${btrfs_opts_base}"
    fi

    case "$FS_TYPE" in
        btrfs)
            info "Mounting btrfs subvolumes (${drive_type} mount options)..."

            mount -o "${btrfs_opts},subvol=@"         "$ROOT_DEVICE" /mnt
            mkdir -p /mnt/home /mnt/var/log /mnt/var/cache/pacman/pkg /mnt/.snapshots

            mount -o "${btrfs_opts},subvol=@home"     "$ROOT_DEVICE" /mnt/home
            mount -o "${btrfs_opts},subvol=@log"      "$ROOT_DEVICE" /mnt/var/log
            mount -o "${btrfs_opts},subvol=@pkg"      "$ROOT_DEVICE" /mnt/var/cache/pacman/pkg
            mount -o "${btrfs_opts},subvol=@snapshots" "$ROOT_DEVICE" /mnt/.snapshots
            ;;
        ext4)
            info "Mounting ${ROOT_DEVICE} on /mnt (ext4)..."
            mount "$ROOT_DEVICE" /mnt
            ;;
    esac

    info "Mounting EFI partition on /mnt/boot..."
    mkdir -p /mnt/boot
    mount "$PART_EFI" /mnt/boot

    ok "Filesystems mounted"
    verify_mounts
}

# ── Verify /mnt is mounted ────────────────────────────────────────────────────
verify_mounts() {
    if ! grep -qs '/mnt' /proc/mounts; then
        die "Nothing is mounted at /mnt. Disk setup failed — check the log for errors above."
    fi
    ok "Mount verification passed"
}

# ── Orchestrator ───────────────────────────────────────────────────────────────
run_disk_setup() {
    local total=6
    local n=0

    (( n++ )) || true; step "$n" "$total" "Partitioning disk ${DISK}..."
    partition_disk

    if [[ "$LUKS" == "yes" ]]; then
        (( n++ )) || true; step "$n" "$total" "Setting up LUKS2 encryption..."
        setup_luks
    else
        (( n++ )) || true; step "$n" "$total" "Skipping encryption (LUKS=no)"
        ROOT_DEVICE="$PART_ROOT"
        export ROOT_DEVICE
    fi

    (( n++ )) || true; step "$n" "$total" "Formatting partitions (${FS_TYPE})..."
    format_partitions

    if [[ "$FS_TYPE" == "btrfs" ]]; then
        (( n++ )) || true; step "$n" "$total" "Creating btrfs subvolumes..."
        create_btrfs_subvolumes
    else
        (( n++ )) || true; step "$n" "$total" "Skipping subvolume creation (FS_TYPE=${FS_TYPE})"
    fi

    (( n++ )) || true; step "$n" "$total" "Mounting filesystems..."
    mount_filesystems

    (( n++ )) || true; step "$n" "$total" "Verifying mounts..."
    verify_mounts

    ok "Disk setup complete"
}
