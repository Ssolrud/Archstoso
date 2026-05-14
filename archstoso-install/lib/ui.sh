#!/usr/bin/env bash
# UI helpers: colors, banner, step/ok/fail/die, confirm, select_option

# ── Colors ────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
DIM="\033[2m"

# ── Log file (set by caller if needed) ────────────────────────────────────────
: "${INSTALL_LOG:=/tmp/archstoso-install.log}"

# ── Banner ────────────────────────────────────────────────────────────────────
banner() {
    echo -e "${CYAN}"
    cat <<'EOF'
 █████╗ ██████╗  ██████╗██╗  ██╗███████╗████████╗ ██████╗ ███████╗ ██████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗
███████║██████╔╝██║     ███████║███████╗   ██║   ██║   ██║███████╗██║   ██║
██╔══██║██╔══██╗██║     ██╔══██║╚════██║   ██║   ██║   ██║╚════██║██║   ██║
██║  ██║██║  ██║╚██████╗██║  ██║███████║   ██║   ╚██████╔╝███████║╚██████╔╝
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚══════╝ ╚═════╝
EOF
    echo -e "${RESET}"
    echo -e "${DIM}$(printf '─%.0s' {1..72})${RESET}"
    echo -e "${WHITE}        Automated Arch Linux Installer — Hyprland Edition${RESET}"
    echo -e "${DIM}$(printf '─%.0s' {1..72})${RESET}"
    echo
}

# ── Section header ─────────────────────────────────────────────────────────────
section() {
    echo
    echo -e "${DIM}$(printf '─%.0s' {1..72})${RESET}"
    echo -e "${BOLD}${BLUE}  $*${RESET}"
    echo -e "${DIM}$(printf '─%.0s' {1..72})${RESET}"
}

# ── Step progress ──────────────────────────────────────────────────────────────
# Usage: step <current> <total> <description>
step() {
    local current="$1" total="$2"
    shift 2
    echo -e "${CYAN}  [${current}/${total}]${RESET} $*"
}

# ── Status suffixes ────────────────────────────────────────────────────────────
ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
fail() { echo -e "  ${RED}✗${RESET} $*"; }
info() { echo -e "  ${YELLOW}→${RESET} $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET}  $*"; }

# ── Fatal error — print context, tail log, exit ────────────────────────────────
die() {
    echo
    echo -e "${RED}$(printf '─%.0s' {1..72})${RESET}"
    echo -e "${RED}${BOLD}  FATAL: $*${RESET}"
    echo -e "${RED}$(printf '─%.0s' {1..72})${RESET}"
    if [[ -f "$INSTALL_LOG" ]]; then
        echo -e "${DIM}  Last lines of ${INSTALL_LOG}:${RESET}"
        tail -n 20 "$INSTALL_LOG" | sed 's/^/  /'
    fi
    echo
    exit 1
}

# ── Yes/no confirmation ────────────────────────────────────────────────────────
# Usage: confirm "Question text" && do_something
# Returns 0 for yes, 1 for no
confirm() {
    local prompt="$1"
    local default="${2:-n}"   # second arg sets default: y or n
    local yn_hint
    if [[ "$default" == "y" ]]; then
        yn_hint="${GREEN}Y${RESET}/n"
    else
        yn_hint="y/${GREEN}N${RESET}"
    fi
    while true; do
        echo -en "  ${YELLOW}?${RESET}  ${prompt} [${yn_hint}] "
        local reply
        read -r reply
        reply="${reply:-$default}"
        case "${reply,,}" in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *) echo -e "  ${RED}Please answer y or n.${RESET}" ;;
        esac
    done
}

# ── Single-line text prompt with optional default ──────────────────────────────
# Usage: ask VAR "Prompt text" ["default value"]
ask() {
    local var="$1" prompt="$2" default="${3:-}"
    local hint=""
    [[ -n "$default" ]] && hint=" ${DIM}[${default}]${RESET}"
    while true; do
        echo -en "  ${YELLOW}?${RESET}  ${prompt}${hint}: "
        local reply
        read -r reply
        reply="${reply:-$default}"
        if [[ -n "$reply" ]]; then
            printf -v "$var" '%s' "$reply"
            return 0
        fi
        echo -e "  ${RED}This field cannot be empty.${RESET}"
    done
}

# ── Password prompt (hidden, confirmed) ───────────────────────────────────────
# Usage: ask_password VAR "Prompt text"
ask_password() {
    local var="$1" prompt="$2"
    while true; do
        echo -en "  ${YELLOW}?${RESET}  ${prompt}: "
        local p1
        read -rs p1; echo
        echo -en "  ${YELLOW}?${RESET}  Confirm ${prompt}: "
        local p2
        read -rs p2; echo
        if [[ "$p1" == "$p2" ]]; then
            if [[ -z "$p1" ]]; then
                echo -e "  ${RED}Password cannot be empty.${RESET}"
                continue
            fi
            printf -v "$var" '%s' "$p1"
            return 0
        fi
        echo -e "  ${RED}Passwords do not match. Try again.${RESET}"
    done
}

# ── Arrow-key single-select menu ──────────────────────────────────────────────
# Usage:
#   options=("opt1" "opt2" "opt3")
#   select_option selected_var "${options[@]}"
#   echo "You chose: $selected_var"
select_option() {
    local retvar="$1"; shift
    local options=("$@")
    local num="${#options[@]}"

    # ANSI helpers
    local ESC=$'\033'
    _cursor_hide()  { printf '%s[?25l' "$ESC"; }
    _cursor_show()  { printf '%s[?25h' "$ESC"; }
    _cursor_up()    { printf '%s[%sA'  "$ESC" "${1:-1}"; }
    _erase_line()   { printf '%s[2K\r' "$ESC"; }

    # Print initial list
    local idx
    for idx in "${!options[@]}"; do
        echo "     ${options[$idx]}"
    done

    local current=0
    _cursor_hide
    # Move back up to the first option
    _cursor_up "$num"

    _redraw() {
        local i
        for i in "${!options[@]}"; do
            _erase_line
            if [[ $i -eq $current ]]; then
                echo -e "  ${CYAN}▶${RESET}  ${BOLD}${options[$i]}${RESET}"
            else
                echo    "     ${options[$i]}"
            fi
        done
        _cursor_up "$num"
    }

    _redraw

    # Ensure cursor is shown even on Ctrl-C
    trap '_cursor_show; echo; exit 1' INT

    while true; do
        local key
        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
        fi
        case "$key" in
            '[A'|'k') (( current > 0 ))          && (( current-- )) ;;
            '[B'|'j') (( current < num - 1 ))    && (( current++ )) ;;
            '')  # Enter
                _cursor_show
                trap - INT
                # Move past the list
                _cursor_up 0
                local i
                for i in "${!options[@]}"; do printf '\n'; done
                printf -v "$retvar" '%s' "${options[$current]}"
                return 0
                ;;
        esac
        _redraw
    done
}
