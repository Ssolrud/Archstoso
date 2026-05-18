#!/usr/bin/env bash
# personal-install.sh — interactive post-install script for personal packages
# Run after the main ArchStoso install is complete.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PKG_FILE="${SCRIPT_DIR}/pkg-files/personal.txt"

# ------------------------------------------------------------------------------
# Colours
# ------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------
_header() { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }
_info()   { echo -e "  ${GREEN}*${RESET} $*"; }
_warn()   { echo -e "  ${YELLOW}!${RESET} $*"; }
_err()    { echo -e "  ${RED}✗${RESET} $*" >&2; }

_command_exists() { command -v "$1" &>/dev/null; }

# ------------------------------------------------------------------------------
# Detect AUR helper
# ------------------------------------------------------------------------------
AUR_HELPER=""
for helper in yay paru; do
    if _command_exists "$helper"; then
        AUR_HELPER="$helper"
        break
    fi
done

if [[ -z "$AUR_HELPER" ]]; then
    _err "No AUR helper found (yay or paru). Install one first."
    exit 1
fi

_info "Using AUR helper: ${AUR_HELPER}"

# ------------------------------------------------------------------------------
# Parse personal.txt into groups
# ------------------------------------------------------------------------------
declare -A GROUP_PKGS   # GROUP_PKGS[GAMING]="steam protonup-qt ..."
declare -a GROUP_ORDER  # preserves display order

while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    group="${line%%:*}"
    pkg="${line#*:}"
    if [[ -z "${GROUP_PKGS[$group]+_}" ]]; then
        GROUP_ORDER+=("$group")
        GROUP_PKGS[$group]=""
    fi
    GROUP_PKGS[$group]+="${pkg} "
done < "$PKG_FILE"

# ------------------------------------------------------------------------------
# Group display names
# ------------------------------------------------------------------------------
declare -A GROUP_LABEL
GROUP_LABEL[GAMING]="Gaming          (steam, protonup-qt, gamemode, mangohud)"
GROUP_LABEL[NVIDIA]="NVIDIA          (nvidia-open-dkms, nvidia-prime, lib32-nvidia-utils, libva-nvidia-driver)"
GROUP_LABEL[VULKAN]="Vulkan / 32-bit (lib32-mesa, vulkan-intel, mesa-utils, lib32-vulkan-*)"
GROUP_LABEL[MEDIA]="Media           (vlc, kodi, yt-dlp)"
GROUP_LABEL[COMMUNICATION]="Communication   (discord)"
GROUP_LABEL[DEVELOPMENT]="Development     (code, nodejs, npm, github-cli)"
GROUP_LABEL[VIRT]="Virtualisation  (qemu-full, edk2-ovmf)"
GROUP_LABEL[UTILS]="Utilities       (htop, smartmontools, sshpass)"

# ------------------------------------------------------------------------------
# Interactive selection
# ------------------------------------------------------------------------------
_header "ArchStoso Personal Package Installer"
echo -e "  Select which groups to install. Answer ${BOLD}y${RESET}/${BOLD}n${RESET} for each.\n"

declare -a SELECTED_PKGS=()

for group in "${GROUP_ORDER[@]}"; do
    label="${GROUP_LABEL[$group]:-$group}"
    echo -ne "  ${BOLD}${label}${RESET}  [y/N] "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        read -ra pkgs <<< "${GROUP_PKGS[$group]}"
        SELECTED_PKGS+=("${pkgs[@]}")
        _info "Added: ${pkgs[*]}"
    fi
done

# ------------------------------------------------------------------------------
# Confirm and install
# ------------------------------------------------------------------------------
if [[ ${#SELECTED_PKGS[@]} -eq 0 ]]; then
    _warn "Nothing selected. Exiting."
    exit 0
fi

echo ""
_header "Packages to install"
for pkg in "${SELECTED_PKGS[@]}"; do
    echo "    - $pkg"
done

echo ""
echo -ne "  ${BOLD}Proceed with installation?${RESET} [y/N] "
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    _warn "Aborted."
    exit 0
fi

_header "Installing packages"
"$AUR_HELPER" -S --needed --noconfirm "${SELECTED_PKGS[@]}"

_header "Done"
_info "All selected packages installed."
