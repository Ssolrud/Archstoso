#!/usr/bin/env bash
# ==============================================================================
# ArchStoso — Dotfiles Installer
# ==============================================================================
# Installs all packages and copies dotfiles to ~/.config/.
# Arch Linux only (pacman + AUR helper).
#
# Usage:
#   ./install.sh [--dry-run]
#
#   --dry-run              Show what would be done without making any changes.
#   ARCHSTOSO_UNATTENDED=1 Skip all interactive prompts (used by the installer).
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PACKAGES_FILE="${SCRIPT_DIR}/packages.txt"
DOTFILES_DIR="${SCRIPT_DIR}"
CONFIG_DIR="${HOME}/.config"
BACKUP_DIR="${HOME}/.config-backup-archstoso-$(date +%Y%m%d-%H%M%S)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NONE='\033[0m'

DRY_RUN=false
UNATTENDED="${ARCHSTOSO_UNATTENDED:-0}"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

_info()    { echo -e "${GREEN}::${NONE} $*"; }
_warn()    { echo -e "${YELLOW}:: WARN${NONE} $*"; }
_error()   { echo -e "${RED}:: ERROR${NONE} $*" >&2; }
_header()  { echo -e "\n${BOLD}${GREEN}$*${NONE}"; }
_dryrun()  { echo -e "${YELLOW}[dry-run]${NONE} $*"; }

_run() {
    # Execute a command, or print it when in dry-run mode.
    if [[ "${DRY_RUN}" == true ]]; then
        _dryrun "$*"
    else
        "$@"
    fi
}

_command_exists() {
    command -v "$1" &>/dev/null
}

_pkg_installed() {
    # Returns 0 if the package is installed (pacman local database).
    pacman -Qq "$1" &>/dev/null
}

# ------------------------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------------------------

for arg in "$@"; do
    case "${arg}" in
        --dry-run)
            DRY_RUN=true
            _warn "Dry-run mode enabled — no changes will be made."
            ;;
        --help|-h)
            echo "Usage: $0 [--dry-run]"
            exit 0
            ;;
        *)
            _error "Unknown argument: ${arg}"
            echo "Usage: $0 [--dry-run]"
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Header
# ------------------------------------------------------------------------------

[[ "$UNATTENDED" != "1" ]] && clear
echo -e "${GREEN}"
cat <<'EOF'
    ___              __   ______
   /   |  __________/ /_ / ____/____  _________  _____
  / /| | / ___/ ___/ __ \/ /    / __ \/ ___/ __ \/ ___/
 / ___ |/ /  / /__/ / / / /___/ /_/ (__  ) /_/ (__  )
/_/  |_/_/   \___/_/ /_/\____/\____/____/\____/____/

EOF
echo -e "${NONE}"
echo "  ArchStoso Dotfiles Installer"
echo "  Hyprland desktop for Arch Linux"
echo

# ------------------------------------------------------------------------------
# Pre-flight checks
# ------------------------------------------------------------------------------

_header "Pre-flight checks"

# Must be Arch Linux
if ! _command_exists pacman; then
    _error "pacman not found. This installer is for Arch Linux only."
    exit 1
fi
_info "Arch Linux detected."

# Must not run as root
if [[ "${EUID}" -eq 0 ]]; then
    _error "Do not run this script as root. It will call sudo when needed."
    exit 1
fi
_info "Running as user: ${USER}"

# packages.txt must exist
if [[ ! -f "${PACKAGES_FILE}" ]]; then
    _error "packages.txt not found at: ${PACKAGES_FILE}"
    exit 1
fi
_info "packages.txt found."

# ------------------------------------------------------------------------------
# AUR helper detection / installation
# ------------------------------------------------------------------------------

_header "AUR helper"

AUR_HELPER=""

_install_yay() {
    _info "Installing yay from AUR..."
    local tmp_dir="${HOME}/Downloads/yay-bin"
    if [[ -d "${tmp_dir}" ]]; then
        _run rm -rf "${tmp_dir}"
    fi
    _run git clone https://aur.archlinux.org/yay-bin.git "${tmp_dir}"
    (
        cd "${tmp_dir}"
        _run makepkg -si --noconfirm
    )
    _info "yay installed successfully."
}

_install_paru() {
    _info "Installing paru from AUR..."
    local tmp_dir="${HOME}/Downloads/paru-bin"
    if [[ -d "${tmp_dir}" ]]; then
        _run rm -rf "${tmp_dir}"
    fi
    _run git clone https://aur.archlinux.org/paru-bin.git "${tmp_dir}"
    (
        cd "${tmp_dir}"
        _run makepkg -si --noconfirm
    )
    _info "paru installed successfully."
}

if _command_exists yay && _command_exists paru; then
    if [[ "$UNATTENDED" == "1" ]]; then
        AUR_HELPER="yay"
        _info "Unattended mode: using yay"
    else
        echo "Both yay and paru are installed."
        read -r -p "Which AUR helper should be used? [yay/paru] (default: yay): " choice
        case "${choice}" in
            paru) AUR_HELPER="paru" ;;
            *)    AUR_HELPER="yay" ;;
        esac
    fi
elif _command_exists yay; then
    AUR_HELPER="yay"
    _info "Using AUR helper: yay"
elif _command_exists paru; then
    AUR_HELPER="paru"
    _info "Using AUR helper: paru"
else
    _warn "No AUR helper found."
    aur_choice=""
    if [[ "$UNATTENDED" == "1" ]]; then
        aur_choice="1"   # always pick yay in unattended mode
        _info "Unattended mode: will install yay"
    else
        echo
        echo "An AUR helper is required to install AUR packages."
        echo "Options:"
        echo "  1) Install yay (default)"
        echo "  2) Install paru"
        echo "  3) Cancel"
        echo
        read -r -p "Choice [1/2/3]: " aur_choice
    fi
    case "${aur_choice}" in
        2)
            if [[ "${DRY_RUN}" == true ]]; then
                _dryrun "Would install paru from AUR."
                AUR_HELPER="paru"
            else
                # Ensure base-devel and git are present first
                if ! _pkg_installed "base-devel"; then
                    sudo pacman --noconfirm -S base-devel
                fi
                if ! _pkg_installed "git"; then
                    sudo pacman --noconfirm -S git
                fi
                _install_paru
                AUR_HELPER="paru"
            fi
            ;;
        3)
            _info "Installation cancelled."
            exit 0
            ;;
        1|*)
            if [[ "${DRY_RUN}" == true ]]; then
                _dryrun "Would install yay from AUR."
                AUR_HELPER="yay"
            else
                if ! _pkg_installed "base-devel"; then
                    sudo pacman --noconfirm -S base-devel
                fi
                if ! _pkg_installed "git"; then
                    sudo pacman --noconfirm -S git
                fi
                _install_yay
                AUR_HELPER="yay"
            fi
            ;;
    esac
fi

_info "AUR helper: ${AUR_HELPER}"

# ------------------------------------------------------------------------------
# Parse packages.txt
# ------------------------------------------------------------------------------

_header "Parsing package list"

pacman_pkgs=()
aur_pkgs=()

while IFS= read -r line || [[ -n "${line}" ]]; do
    # Strip inline comments and trim whitespace
    line="${line%%#*}"
    line="${line// /}"     # remove all spaces (package names have no spaces)
    line="${line//	/}"  # remove tabs

    # Skip empty lines
    [[ -z "${line}" ]] && continue

    pacman_pkgs+=("${line}")
done < "${PACKAGES_FILE}"

# Re-parse to split pacman vs AUR accurately using the [AUR] marker in the
# raw file. We read raw lines this time to inspect comments.
pacman_pkgs=()
aur_pkgs=()

while IFS= read -r raw_line; do
    # Skip pure comment lines (start with #) and blank lines
    stripped="${raw_line%%#*}"
    pkg="${stripped//[[:space:]]/}"
    [[ -z "${pkg}" ]] && continue

    # If the original line contains [AUR], route to aur_pkgs
    if [[ "${raw_line}" == *"[AUR]"* ]]; then
        aur_pkgs+=("${pkg}")
    else
        pacman_pkgs+=("${pkg}")
    fi
done < "${PACKAGES_FILE}"

_info "pacman packages : ${#pacman_pkgs[@]}"
_info "AUR packages    : ${#aur_pkgs[@]}"

# ------------------------------------------------------------------------------
# Install pacman packages
# ------------------------------------------------------------------------------

_header "Installing pacman packages"

pacman_missing=()
for pkg in "${pacman_pkgs[@]}"; do
    if ! _pkg_installed "${pkg}"; then
        pacman_missing+=("${pkg}")
    else
        _info "[already installed] ${pkg}"
    fi
done

if [[ ${#pacman_missing[@]} -gt 0 ]]; then
    _info "Installing ${#pacman_missing[@]} missing pacman package(s)..."
    _run sudo pacman --noconfirm -S "${pacman_missing[@]}"
else
    _info "All pacman packages already installed."
fi

# ------------------------------------------------------------------------------
# Install AUR packages
# ------------------------------------------------------------------------------

_header "Installing AUR packages"

aur_missing=()
for pkg in "${aur_pkgs[@]}"; do
    if ! _pkg_installed "${pkg}"; then
        aur_missing+=("${pkg}")
    else
        _info "[already installed] ${pkg}"
    fi
done

if [[ ${#aur_missing[@]} -gt 0 ]]; then
    _info "Installing ${#aur_missing[@]} missing AUR package(s) via ${AUR_HELPER}..."
    _run "${AUR_HELPER}" --noconfirm -S "${aur_missing[@]}"
else
    _info "All AUR packages already installed."
fi

# ------------------------------------------------------------------------------
# Create swww compatibility symlinks (Arch extra ships awww with renamed binaries)
# ------------------------------------------------------------------------------

_header "Creating swww → awww symlinks"

if _command_exists awww-daemon; then
    _info "Linking swww-daemon → awww-daemon"
    sudo ln -sf /usr/bin/awww-daemon /usr/local/bin/swww-daemon
    sudo ln -sf /usr/bin/awww /usr/local/bin/swww
else
    _warn "awww-daemon not found — skipping swww symlinks"
fi

# Enable elephant user service (Walker data backend)
# ------------------------------------------------------------------------------

_header "Enabling elephant service"

if _command_exists elephant; then
    _info "Enabling elephant systemd user service..."
    _run elephant service enable
    # systemctl --user start fails in a chroot (no D-Bus session); best-effort only
    _run systemctl --user start elephant.service 2>/dev/null || \
        _warn "Could not start elephant.service — it will start on first login"
else
    _warn "elephant not found — skipping service setup. Install elephant and run: elephant service enable"
fi

# ------------------------------------------------------------------------------
# Oh My Posh — install binary if oh-my-posh-bin is not available
# (fallback: official install script to ~/.local/bin)
# ------------------------------------------------------------------------------

if ! _command_exists oh-my-posh; then
    _header "Oh My Posh"
    _info "oh-my-posh not found — installing via official script to ~/.local/bin ..."
    _run mkdir -p "${HOME}/.local/bin"
    if [[ "${DRY_RUN}" == false ]]; then
        curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "${HOME}/.local/bin"
    else
        _dryrun "Would run: curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin"
    fi
fi

# ------------------------------------------------------------------------------
# Create required user directories
# ------------------------------------------------------------------------------

_header "Creating user directories"
_run mkdir -p "${HOME}/wallpaper"
_run mkdir -p "${HOME}/Pictures"
_info "User directories ready."

# ------------------------------------------------------------------------------
# Backup existing ~/.config directories
# ------------------------------------------------------------------------------

_header "Backing up existing configs"

# Config directories we are about to overwrite
config_dirs=(
    "archstoso"
    "bashrc"
    "btop"
    "fastfetch"
    "gtk-3.0"
    "gtk-4.0"
    "hypr"
    "kitty"
    "matugen"
    "nvim"
    "ohmyposh"
    "qt6ct"
    "sidepad"
    "swaync"
    "walker"
    "waybar"
    "waypaper"
    "wlogout"
)
# Flat config files we are about to overwrite
config_files=(
    "chromium-flags.conf"
    "edge-flags.conf"
    "kdeglobals"
)

backup_needed=false
for dir in "${config_dirs[@]}"; do
    if [[ -d "${CONFIG_DIR}/${dir}" ]]; then
        backup_needed=true
        break
    fi
done
if [[ "${backup_needed}" == false ]]; then
    for f in "${config_files[@]}"; do
        if [[ -f "${CONFIG_DIR}/${f}" ]]; then
            backup_needed=true
            break
        fi
    done
fi

if [[ "${backup_needed}" == true ]]; then
    _info "Backing up existing configs to: ${BACKUP_DIR}"
    _run mkdir -p "${BACKUP_DIR}"

    for dir in "${config_dirs[@]}"; do
        if [[ -d "${CONFIG_DIR}/${dir}" ]]; then
            _info "  Backing up ~/.config/${dir}"
            _run cp -r "${CONFIG_DIR}/${dir}" "${BACKUP_DIR}/"
        fi
    done
    for f in "${config_files[@]}"; do
        if [[ -f "${CONFIG_DIR}/${f}" ]]; then
            _info "  Backing up ~/.config/${f}"
            _run cp "${CONFIG_DIR}/${f}" "${BACKUP_DIR}/"
        fi
    done
else
    _info "No existing configs to back up."
fi

# ------------------------------------------------------------------------------
# Copy dotfiles to ~/.config/
# ------------------------------------------------------------------------------

_header "Installing dotfiles"

_run mkdir -p "${CONFIG_DIR}"

for dir in "${config_dirs[@]}"; do
    src="${DOTFILES_DIR}/${dir}"
    if [[ -d "${src}" ]]; then
        _info "  Installing ~/.config/${dir}"
        _run cp -r "${src}" "${CONFIG_DIR}/"
    fi
done

for f in "${config_files[@]}"; do
    src="${DOTFILES_DIR}/${f}"
    if [[ -f "${src}" ]]; then
        _info "  Installing ~/.config/${f}"
        _run cp "${src}" "${CONFIG_DIR}/"
    fi
done

# ------------------------------------------------------------------------------
# Ensure ~/.local/bin exists (used by archstoso scripts)
# ------------------------------------------------------------------------------

if [[ ! -d "${HOME}/.local/bin" ]]; then
    _info "Creating ~/.local/bin"
    _run mkdir -p "${HOME}/.local/bin"
fi

# ------------------------------------------------------------------------------
# Environment variable defaults in ~/.bashrc
# ------------------------------------------------------------------------------

_header "Setting up environment variables"

BASHRC="${HOME}/.bashrc"

_append_env_if_missing() {
    local var_name="$1"
    local var_value="$2"
    local comment="$3"

    if grep -q "export ${var_name}=" "${BASHRC}" 2>/dev/null; then
        _info "  ${var_name} already set in ~/.bashrc — skipping."
    else
        _info "  Adding ${var_name}=${var_value} to ~/.bashrc"
        if [[ "${DRY_RUN}" == false ]]; then
            {
                echo ""
                echo "# ${comment} (added by ArchStoso installer)"
                echo "export ${var_name}=\"${var_value}\""
            } >> "${BASHRC}"
        else
            _dryrun "Would append: export ${var_name}=\"${var_value}\" to ~/.bashrc"
        fi
    fi
}

_append_env_if_missing "BROWSER"      "brave"      "Default browser"
_append_env_if_missing "TERMINAL"     "kitty"      "Default terminal"
_append_env_if_missing "EDITOR"       "nvim"       "Default editor"
_append_env_if_missing "FILE_MANAGER" "thunar"     "Default file manager"

# Source the modular bashrc configs if not already done
if ! grep -q "\.config/bashrc" "${BASHRC}" 2>/dev/null; then
    _info "  Wiring modular bashrc configs into ~/.bashrc"
    if [[ "${DRY_RUN}" == false ]]; then
        {
            echo ""
            echo "# ArchStoso modular bashrc (added by ArchStoso installer)"
            echo "for _archstoso_rc in \"\${HOME}/.config/bashrc/\"*; do"
            echo "    # shellcheck source=/dev/null"
            echo "    [[ -r \"\${_archstoso_rc}\" ]] && source \"\${_archstoso_rc}\""
            echo "done"
            echo "unset _archstoso_rc"
        } >> "${BASHRC}"
    else
        _dryrun "Would add ~/.config/bashrc sourcing loop to ~/.bashrc"
    fi
else
    _info "  Modular bashrc sourcing already present — skipping."
fi

# ------------------------------------------------------------------------------
# XDG user directories
# ------------------------------------------------------------------------------

if _command_exists xdg-user-dirs-update; then
    _info "Updating XDG user directories..."
    _run xdg-user-dirs-update
fi

# ------------------------------------------------------------------------------
# Enable / start NetworkManager if not running
# ------------------------------------------------------------------------------

if ! systemctl is-active --quiet NetworkManager 2>/dev/null; then
    _info "Enabling and starting NetworkManager..."
    _run sudo systemctl enable --now NetworkManager
fi

# ------------------------------------------------------------------------------
# Make archstoso scripts executable
# ------------------------------------------------------------------------------

_header "Setting script permissions"

if [[ -d "${CONFIG_DIR}/archstoso/scripts" ]]; then
    _info "Making archstoso scripts executable..."
    if [[ "${DRY_RUN}" == false ]]; then
        find "${CONFIG_DIR}/archstoso/scripts" -type f -exec chmod +x {} \;
        find "${CONFIG_DIR}/archstoso/bin" -type f -exec chmod +x {} \; 2>/dev/null || true
    else
        _dryrun "Would chmod +x all files in ~/.config/archstoso/scripts/ and bin/"
    fi
fi

# Hyprland scripts
if [[ -d "${CONFIG_DIR}/hypr/scripts" ]]; then
    if [[ "${DRY_RUN}" == false ]]; then
        find "${CONFIG_DIR}/hypr/scripts" -type f -exec chmod +x {} \;
    else
        _dryrun "Would chmod +x all files in ~/.config/hypr/scripts/"
    fi
fi

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------

echo
echo -e "${GREEN}${BOLD}=================================================================${NONE}"
echo -e "${GREEN}${BOLD}  ArchStoso installation complete!${NONE}"
echo -e "${GREEN}${BOLD}=================================================================${NONE}"
echo
echo "  Dotfiles installed to : ${CONFIG_DIR}"
if [[ "${backup_needed}" == true ]]; then
    echo "  Previous configs backed up to:"
    echo "    ${BACKUP_DIR}"
fi
echo
echo "  Next steps:"
echo "    1. Log out of your current session."
echo "    2. Select Hyprland from your display manager (or run: uwsm start hyprland)."
echo "    3. Customize ~/.config/hypr/conf/custom.conf for personal overrides."
echo "    4. Set your wallpaper with: waypaper"
echo
if [[ "${DRY_RUN}" == true ]]; then
    echo -e "${YELLOW}  (dry-run — no changes were made)${NONE}"
    echo
fi
