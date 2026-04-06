#!/bin/bash

################################################################################
# Arch Linux System Status Report
# Comprehensive hardware and software information gathering script
################################################################################

# Color definitions for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# Unicode box drawing characters
readonly BOX_H="━"
readonly BOX_V="┃"
readonly BOX_TL="┏"
readonly BOX_TR="┓"
readonly BOX_BL="┗"
readonly BOX_BR="┛"
readonly BOX_VR="┣"
readonly BOX_VL="┫"
readonly BULLET="•"

################################################################################
# Helper Functions
################################################################################

# Print a section header
print_header() {
    local title="$1"
    local width=80
    local title_len=${#title}
    local padding=$(( (width - title_len - 2) / 2 ))

    echo -e "\n${CYAN}${BOX_TL}$(printf "${BOX_H}%.0s" {1..78})${BOX_TR}${RESET}"
    printf "${CYAN}${BOX_V}${RESET}${BOLD}${WHITE}%*s%s%*s${RESET}${CYAN}${BOX_V}${RESET}\n" \
           $padding "" "$title" $((width - padding - title_len - 2)) ""
    echo -e "${CYAN}${BOX_BL}$(printf "${BOX_H}%.0s" {1..78})${BOX_BR}${RESET}\n"
}

# Print a subheader
print_subheader() {
    echo -e "${YELLOW}${BOLD}▶ $1${RESET}"
}

# Print an info line
print_info() {
    echo -e "${GREEN}  ${BULLET}${RESET} ${WHITE}$1:${RESET} $2"
}

# Print a warning
print_warning() {
    echo -e "${YELLOW}  ⚠ $1${RESET}"
}

# Print an error
print_error() {
    echo -e "${RED}  ✗ $1${RESET}"
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Get value or return "Not found"
get_or_default() {
    local value="$1"
    local default="${2:-Not found}"
    [[ -n "$value" ]] && echo "$value" || echo "$default"
}

################################################################################
# Hardware Information Functions
################################################################################

get_cpu_info() {
    print_subheader "CPU Information"

    local cpu_model=$(lscpu | grep "Model name:" | sed 's/Model name: *//')
    local cpu_arch=$(lscpu | grep "Architecture:" | awk '{print $2}')
    local cpu_cores=$(lscpu | grep "^Core(s) per socket:" | awk '{print $NF}')
    local cpu_threads=$(lscpu | grep "^CPU(s):" | head -1 | awk '{print $NF}')
    local cpu_sockets=$(lscpu | grep "Socket(s):" | awk '{print $NF}')
    local cpu_mhz=$(lscpu | grep "CPU MHz:" | awk '{print $NF}')
    local cpu_max_mhz=$(lscpu | grep "CPU max MHz:" | awk '{print $NF}')

    print_info "Model" "$cpu_model"
    print_info "Architecture" "$cpu_arch"
    print_info "Sockets" "$cpu_sockets"
    print_info "Cores per socket" "$cpu_cores"
    print_info "Total threads" "$cpu_threads"
    [[ -n "$cpu_mhz" ]] && print_info "Current MHz" "${cpu_mhz} MHz"
    [[ -n "$cpu_max_mhz" ]] && print_info "Max MHz" "${cpu_max_mhz} MHz"

    echo
}

get_memory_info() {
    print_subheader "Memory Information"

    local mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    local mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    local mem_available=$(free -h | awk '/^Mem:/ {print $7}')
    local swap_total=$(free -h | awk '/^Swap:/ {print $2}')
    local swap_used=$(free -h | awk '/^Swap:/ {print $3}')

    print_info "Total RAM" "$mem_total"
    print_info "Used RAM" "$mem_used"
    print_info "Available RAM" "$mem_available"
    print_info "Total Swap" "$swap_total"
    print_info "Used Swap" "$swap_used"

    echo
}

get_gpu_info() {
    print_subheader "GPU Information"

    if command_exists lspci; then
        local gpu_count=0
        while IFS= read -r line; do
            ((gpu_count++))
            print_info "GPU $gpu_count" "$line"
        done < <(lspci | grep -E "VGA|3D|Display" | sed 's/.*: //')

        [[ $gpu_count -eq 0 ]] && print_warning "No GPU detected via lspci"
    else
        print_error "lspci not found (install pciutils)"
    fi

    # Check for loaded graphics drivers
    if [[ -d /sys/module/nvidia ]]; then
        local nvidia_version=$(modinfo nvidia 2>/dev/null | grep "^version:" | awk '{print $2}')
        print_info "NVIDIA Driver" "Loaded (version: ${nvidia_version:-unknown})"
    fi

    if [[ -d /sys/module/amdgpu ]]; then
        print_info "AMD Driver" "amdgpu loaded"
    fi

    if [[ -d /sys/module/i915 ]]; then
        print_info "Intel Driver" "i915 loaded"
    fi

    echo
}

get_disk_info() {
    print_subheader "Disk & Storage Information"

    # Block devices
    if command_exists lsblk; then
        echo -e "${WHITE}  Block Devices:${RESET}"
        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE | while IFS= read -r line; do
            echo -e "    ${CYAN}$line${RESET}"
        done
        echo
    fi

    # Filesystem usage
    echo -e "${WHITE}  Filesystem Usage:${RESET}"
    df -h -x tmpfs -x devtmpfs -x squashfs | tail -n +2 | while IFS= read -r line; do
        echo -e "    ${GREEN}$line${RESET}"
    done

    echo
}

get_network_info() {
    print_subheader "Network Interfaces"

    if command_exists ip; then
        while IFS= read -r iface; do
            local iface_name=$(echo "$iface" | awk '{print $2}' | tr -d ':')
            local iface_state=$(echo "$iface" | grep -oP '(?<=state )\w+')
            local ip_addr=$(ip addr show "$iface_name" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)

            if [[ "$iface_name" != "lo" ]]; then
                print_info "$iface_name" "State: $iface_state, IP: ${ip_addr:-No IP}"
            fi
        done < <(ip link show | grep "^[0-9]")
    else
        print_error "ip command not found (install iproute2)"
    fi

    echo
}

get_audio_info() {
    print_subheader "Audio Devices"

    if command_exists aplay; then
        local card_count=$(aplay -l 2>/dev/null | grep "^card" | wc -l)
        print_info "Sound cards detected" "$card_count"

        aplay -l 2>/dev/null | grep "^card" | while IFS= read -r line; do
            echo -e "    ${CYAN}$line${RESET}"
        done
    else
        print_warning "aplay not found (install alsa-utils)"
    fi

    # PipeWire/PulseAudio status
    if systemctl --user is-active pipewire.service &>/dev/null; then
        print_info "PipeWire" "Running"
    elif systemctl --user is-active pulseaudio.service &>/dev/null; then
        print_info "PulseAudio" "Running"
    fi

    echo
}

get_usb_info() {
    print_subheader "USB Devices"

    if command_exists lsusb; then
        local usb_count=$(lsusb | wc -l)
        print_info "USB devices detected" "$usb_count"
        echo
        lsusb | while IFS= read -r line; do
            echo -e "    ${CYAN}$line${RESET}"
        done
    else
        print_error "lsusb not found (install usbutils)"
    fi

    echo
}

get_battery_info() {
    print_subheader "Battery Status"

    if [[ -d /sys/class/power_supply/BAT0 ]] || [[ -d /sys/class/power_supply/BAT1 ]]; then
        for bat in /sys/class/power_supply/BAT*; do
            [[ -d "$bat" ]] || continue
            local bat_name=$(basename "$bat")
            local capacity=$(cat "$bat/capacity" 2>/dev/null)
            local status=$(cat "$bat/status" 2>/dev/null)
            print_info "$bat_name" "Capacity: ${capacity}%, Status: $status"
        done
    else
        print_warning "No battery detected (desktop system)"
    fi

    echo
}

################################################################################
# Software Information Functions
################################################################################

get_system_info() {
    print_subheader "System Information"

    local hostname=$(hostname)
    local kernel=$(uname -r)
    local arch=$(uname -m)
    local uptime=$(uptime -p | sed 's/up //')

    print_info "Hostname" "$hostname"
    print_info "Kernel" "$kernel"
    print_info "Architecture" "$arch"
    print_info "Uptime" "$uptime"

    echo
}

get_display_server_info() {
    print_subheader "Display Server & Desktop Environment"

    local session_type="${XDG_SESSION_TYPE:-Unknown}"
    print_info "Session Type" "$session_type"

    # Check for Wayland compositor
    if [[ "$session_type" == "wayland" ]]; then
        if pgrep -x hyprland &>/dev/null; then
            print_info "Wayland Compositor" "Hyprland"
        elif pgrep -x sway &>/dev/null; then
            print_info "Wayland Compositor" "Sway"
        elif pgrep -x wayfire &>/dev/null; then
            print_info "Wayland Compositor" "Wayfire"
        else
            print_info "Wayland Compositor" "Unknown"
        fi
    fi

    # Desktop environment detection
    local de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-Unknown}}"
    print_info "Desktop Environment" "$de"

    # Window manager (for X11)
    if [[ "$session_type" == "x11" ]]; then
        local wm=$(wmctrl -m 2>/dev/null | grep "Name:" | cut -d' ' -f2)
        [[ -n "$wm" ]] && print_info "Window Manager" "$wm"
    fi

    echo
}

get_shell_info() {
    print_subheader "Shell Information"

    print_info "Current Shell" "$SHELL"

    if command_exists bash; then
        print_info "Bash Version" "$(bash --version | head -1 | awk '{print $4}')"
    fi

    if command_exists zsh; then
        print_info "Zsh Version" "$(zsh --version | awk '{print $2}')"
    fi

    if command_exists fish; then
        print_info "Fish Version" "$(fish --version | awk '{print $3}')"
    fi

    echo
}

get_package_info() {
    print_subheader "Package Manager Information"

    if command_exists pacman; then
        local total_pkgs=$(pacman -Q | wc -l)
        local explicit_pkgs=$(pacman -Qe | wc -l)
        local aur_pkgs=$(pacman -Qm | wc -l)

        print_info "Total Packages" "$total_pkgs"
        print_info "Explicitly Installed" "$explicit_pkgs"
        print_info "AUR Packages" "$aur_pkgs"
    else
        print_error "pacman not found"
    fi

    # AUR helper detection
    if command_exists yay; then
        print_info "AUR Helper" "yay ($(yay --version | head -1))"
    elif command_exists paru; then
        print_info "AUR Helper" "paru ($(paru --version | head -1))"
    elif command_exists trizen; then
        print_info "AUR Helper" "trizen"
    else
        print_warning "No AUR helper detected"
    fi

    echo
}

get_development_tools() {
    print_subheader "Development Tools"

    local tools=(
        "git:Git"
        "gcc:GCC"
        "clang:Clang"
        "python:Python"
        "python3:Python3"
        "node:Node.js"
        "npm:NPM"
        "cargo:Rust"
        "go:Go"
        "java:Java"
        "javac:Java Compiler"
        "make:GNU Make"
        "cmake:CMake"
        "docker:Docker"
        "podman:Podman"
    )

    for tool in "${tools[@]}"; do
        IFS=':' read -r cmd name <<< "$tool"
        if command_exists "$cmd"; then
            local version=$("$cmd" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            print_info "$name" "Installed${version:+ (v$version)}"
        fi
    done

    echo
}

get_common_apps() {
    print_subheader "Common Applications"

    # Terminal emulators
    local terminals=("alacritty:Alacritty" "kitty:Kitty" "foot:Foot" "wezterm:WezTerm" "terminator:Terminator" "gnome-terminal:GNOME Terminal")
    for term in "${terminals[@]}"; do
        IFS=':' read -r cmd name <<< "$term"
        command_exists "$cmd" && print_info "Terminal" "$name"
    done

    # Browsers
    local browsers=("firefox:Firefox" "chromium:Chromium" "brave:Brave" "google-chrome:Google Chrome")
    for browser in "${browsers[@]}"; do
        IFS=':' read -r cmd name <<< "$browser"
        command_exists "$cmd" && print_info "Browser" "$name"
    done

    # Editors
    local editors=("nvim:Neovim" "vim:Vim" "code:VS Code" "emacs:Emacs" "nano:Nano")
    for editor in "${editors[@]}"; do
        IFS=':' read -r cmd name <<< "$editor"
        if command_exists "$cmd"; then
            local version=$("$cmd" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            print_info "Editor" "$name${version:+ (v$version)}"
        fi
    done

    echo
}

get_systemd_services() {
    print_subheader "Systemd Services (Enabled)"

    echo -e "${WHITE}  System Services:${RESET}"
    systemctl list-unit-files --state=enabled --type=service --no-pager --no-legend | head -20 | while IFS= read -r line; do
        echo -e "    ${GREEN}${BULLET}${RESET} ${CYAN}$(echo $line | awk '{print $1}')${RESET}"
    done

    echo
    echo -e "${WHITE}  User Services:${RESET}"
    systemctl --user list-unit-files --state=enabled --type=service --no-pager --no-legend 2>/dev/null | head -20 | while IFS= read -r line; do
        echo -e "    ${GREEN}${BULLET}${RESET} ${CYAN}$(echo $line | awk '{print $1}')${RESET}"
    done

    echo
}

get_bootloader_info() {
    print_subheader "Boot Loader Information"

    # Check for GRUB
    if command_exists grub-install; then
        print_info "Boot Loader" "GRUB"
        local grub_version=$(grub-install --version | awk '{print $NF}')
        print_info "GRUB Version" "$grub_version"
    fi

    # Check for systemd-boot
    if [[ -d /boot/loader/entries ]] && command_exists bootctl; then
        print_info "Boot Loader" "systemd-boot"
        bootctl status 2>/dev/null | grep "Product:" | sed 's/.*Product: //' | while read -r line; do
            print_info "Version" "$line"
        done
    fi

    # Check for rEFInd
    if [[ -d /boot/EFI/refind ]] || [[ -d /boot/efi/EFI/refind ]]; then
        print_info "Boot Loader" "rEFInd"
    fi

    # Boot mode
    if [[ -d /sys/firmware/efi ]]; then
        print_info "Boot Mode" "UEFI"
    else
        print_info "Boot Mode" "Legacy BIOS"
    fi

    echo
}

get_explicitly_installed_packages() {
    print_subheader "Explicitly Installed Packages (First 50)"

    if command_exists pacman; then
        echo -e "${WHITE}  Package List:${RESET}"
        pacman -Qe | head -50 | while IFS= read -r line; do
            echo -e "    ${CYAN}$line${RESET}"
        done

        local total=$(pacman -Qe | wc -l)
        if [[ $total -gt 50 ]]; then
            echo -e "\n    ${YELLOW}... and $((total - 50)) more packages${RESET}"
            echo -e "    ${WHITE}Use 'pacman -Qe' to see full list${RESET}"
        fi
    fi

    echo
}

################################################################################
# Main Execution
################################################################################

main() {
    clear

    echo -e "${BOLD}${MAGENTA}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                                                                           ║
    ║                  █████╗ ██████╗  ██████╗██╗  ██╗                         ║
    ║                 ██╔══██╗██╔══██╗██╔════╝██║  ██║                         ║
    ║                 ███████║██████╔╝██║     ███████║                         ║
    ║                 ██╔══██║██╔══██╗██║     ██╔══██║                         ║
    ║                 ██║  ██║██║  ██║╚██████╗██║  ██║                         ║
    ║                 ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                         ║
    ║                                                                           ║
    ║                    SYSTEM STATUS REPORT                                   ║
    ║                                                                           ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"

    echo -e "${WHITE}Generated: $(date '+%Y-%m-%d %H:%M:%S')${RESET}\n"

    # Hardware Information
    print_header "HARDWARE INFORMATION"
    get_cpu_info
    get_memory_info
    get_gpu_info
    get_disk_info
    get_network_info
    get_audio_info
    get_usb_info
    get_battery_info

    # Software Information
    print_header "SOFTWARE INFORMATION"
    get_system_info
    get_display_server_info
    get_shell_info
    get_package_info
    get_development_tools
    get_common_apps
    get_systemd_services
    get_bootloader_info
    get_explicitly_installed_packages

    # Footer
    echo -e "${CYAN}${BOX_TL}$(printf "${BOX_H}%.0s" {1..78})${BOX_TR}${RESET}"
    echo -e "${CYAN}${BOX_V}${RESET}${WHITE}                          End of System Report                           ${RESET}${CYAN}${BOX_V}${RESET}"
    echo -e "${CYAN}${BOX_BL}$(printf "${BOX_H}%.0s" {1..78})${BOX_BR}${RESET}\n"
}

# Run main function
main "$@"
