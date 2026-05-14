#!/usr/bin/env bash
# Environment checks and input validators.
# Requires ui.sh to be sourced first (uses ok, fail, warn, die, info).

# ── Environment checks ────────────────────────────────────────────────────────
# These run once at startup in archstoso.sh before any prompts or disk writes.

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        die "This installer must be run as root. Try: sudo ./archstoso.sh"
    fi
    ok "Running as root"
}

check_arch_iso() {
    if [[ ! -f /etc/arch-release ]]; then
        die "This installer must be run from an Arch Linux live ISO."
    fi
    ok "Arch Linux environment confirmed"
}

check_uefi() {
    if [[ ! -d /sys/firmware/efi ]]; then
        die "UEFI mode not detected. This installer requires a UEFI system. Reboot in UEFI mode."
    fi
    ok "UEFI mode confirmed"
}

check_internet() {
    info "Checking internet connectivity..."
    if ! ping -c 1 -W 5 archlinux.org &>/dev/null; then
        die "No internet connection detected. Connect to the network and retry."
    fi
    ok "Internet connectivity confirmed"
}

check_pacman_lock() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        die "Pacman is locked (/var/lib/pacman/db.lck exists). Remove it if no pacman process is running."
    fi
    ok "Pacman is not locked"
}

check_ram() {
    local total_kb
    total_kb=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
    local total_mb; total_mb=$(( total_kb / 1024 ))
    if [[ $total_mb -lt 512 ]]; then
        die "System has less than 512MB RAM (${total_mb}MB). Cannot continue."
    elif [[ $total_mb -lt 2048 ]]; then
        warn "Low RAM detected (${total_mb}MB). Installation may be slow."
    else
        ok "RAM: ${total_mb}MB"
    fi
}

# Run all environment checks in sequence.
run_environment_checks() {
    section "Environment Checks"
    check_root
    check_arch_iso
    check_uefi
    check_internet
    check_pacman_lock
    check_ram
}

# ── Input validators ───────────────────────────────────────────────────────────
# Each returns 0 (valid) or 1 (invalid) and prints an error message on failure.
# Designed to be used inside ask() retry loops.

# Valid Linux username: starts with a-z or _, 1–32 chars, a-z0-9_- only.
validate_username() {
    local val="$1"
    if [[ ! "${val,,}" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
        echo -e "  ${RED}Invalid username.${RESET} Must start with a letter/underscore, max 32 chars, a-z/0-9/-/_ only."
        return 1
    fi
    return 0
}

# Valid hostname: RFC 1123 — alphanumeric and hyphens, no leading/trailing hyphen, max 63 chars.
validate_hostname() {
    local val="$1"
    if [[ ! "$val" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
        echo -e "  ${RED}Invalid hostname.${RESET} Use letters, digits, and hyphens. No leading/trailing hyphens. Max 63 chars."
        return 1
    fi
    return 0
}

# Valid timezone: must exist in the tz database.
validate_timezone() {
    local val="$1"
    if [[ ! -f "/usr/share/zoneinfo/${val}" ]]; then
        echo -e "  ${RED}Unknown timezone '${val}'.${RESET} Example: Europe/Oslo"
        return 1
    fi
    return 0
}

# Valid console keymap: must be loadable by loadkeys.
validate_keymap() {
    local val="$1"
    if ! localectl list-keymaps 2>/dev/null | grep -qx "$val"; then
        echo -e "  ${RED}Unknown keymap '${val}'.${RESET} Run 'localectl list-keymaps' to see available options."
        return 1
    fi
    return 0
}

# Valid locale: must exist in /etc/locale.gen (or the glibc locale list).
validate_locale() {
    local val="$1"
    if ! grep -q "^#\?${val} " /etc/locale.gen 2>/dev/null; then
        echo -e "  ${RED}Unknown locale '${val}'.${RESET} Example: en_US.UTF-8"
        return 1
    fi
    return 0
}

# Valid block device disk path (e.g. /dev/sda, /dev/nvme0n1).
validate_disk() {
    local val="$1"
    if [[ ! -b "$val" ]]; then
        echo -e "  ${RED}'${val}' is not a block device.${RESET} Select a disk from the list."
        return 1
    fi
    return 0
}

# ── Validated ask wrapper ──────────────────────────────────────────────────────
# Like ask() but runs a validator after each input.
# Usage: ask_validated VAR "Prompt" validate_fn ["default"]
ask_validated() {
    local var="$1" prompt="$2" validator="$3" default="${4:-}"
    local hint=""
    [[ -n "$default" ]] && hint=" ${DIM}[${default}]${RESET}"
    while true; do
        echo -en "  ${YELLOW}?${RESET}  ${prompt}${hint}: "
        local reply
        read -r reply
        reply="${reply:-$default}"
        if [[ -z "$reply" ]]; then
            echo -e "  ${RED}This field cannot be empty.${RESET}"
            continue
        fi
        if "$validator" "$reply"; then
            printf -v "$var" '%s' "$reply"
            return 0
        fi
    done
}

# ── Disk auto-detect helpers ───────────────────────────────────────────────────

# Detect timezone via GeoIP. Echoes the timezone string or empty string on failure.
detect_timezone() {
    curl -s --max-time 5 https://ipapi.co/timezone 2>/dev/null || true
}

# List available disks as "/dev/sdX (SIZE)" for display in select_option.
list_disks() {
    lsblk -dpno NAME,SIZE,MODEL | awk '{
        model = ""
        for (i=3; i<=NF; i++) model = model (i==3 ? "" : " ") $i
        if (model == "") model = "unknown"
        printf "%s  (%s — %s)\n", $1, $2, model
    }'
}

# Extract just the device path from a list_disks entry (strips size/model).
disk_path_from_entry() {
    echo "$1" | awk '{print $1}'
}

# Returns "ssd" or "hdd" for a given device path.
detect_drive_type() {
    local disk="$1"
    local dev
    dev=$(basename "$disk")
    local rotational
    rotational=$(cat "/sys/block/${dev}/queue/rotational" 2>/dev/null || echo "1")
    if [[ "$rotational" == "0" ]]; then
        echo "ssd"
    else
        echo "hdd"
    fi
}
