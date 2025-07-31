#!/usr/bin/env bash
set -euo pipefail

# A robust bootstrap script to set up a new machine.
# This script prepares the system with the bare essentials and then hands
# off to chezmoi to manage the rest of the configuration declaratively.
#
# It performs the following steps:
# 1. Installs basic tools (git, curl, gpg) needed for repository setup.
# 2. Adds the 1Password repository and GPG key.
# 3. Installs the 1Password CLI.
# 4. Installs chezmoi itself.
# 5. Runs a two-pass chezmoi 'apply' to handle initial setup and secret generation.

# —————— Configuration ——————
DOTFILES_BRANCH="main"


# —————— COLORS & LOGGING ——————
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "\n${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }


# —————— SCRIPT LOGIC ——————
main() {
    if [[ $EUID -eq 0 ]]; then
       log_error "This script must be run as a standard user, not as root."
       exit 1
    fi

    log_info "Starting bootstrap process..."

    # Ensure system time is accurate to prevent apt errors
    log_info "Synchronizing system time..."
    sudo timedatectl set-ntp true

    # Check for 1Password CLI
    if ! command -v op >/dev/null 2>&1; then
        log_error "1Password CLI (op) is not installed. Please install it before running this script."
        exit 1
    fi

    if ! op account get >/dev/null 2>&1; then
        log_error "You are not signed in to 1Password CLI. Please run: eval \$(op signin)"
        exit 1
    fi

    # 1. Install basic tools needed for repository setup
    log_info "Installing basic tools (git, gpg)..."
    if command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        sudo pacman -Sy --noconfirm git gnupg
    elif command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt-get update -qq
        sudo apt-get install -y -qq git gpg
    else
        log_error "Unsupported package manager. Please install git and gpg manually."
        exit 1
    fi
    log_success "Basic tools installed."

    # 2. Install chezmoi
    CHEZMOI_INSTALL_DIR="$HOME/.local/bin"
    if ! command -v chezmoi >/dev/null 2>&1; then
        log_info "Installing chezmoi to $CHEZMOI_INSTALL_DIR..."
        mkdir -p "$CHEZMOI_INSTALL_DIR"
        export PATH="$CHEZMOI_INSTALL_DIR:$PATH"
        sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$CHEZMOI_INSTALL_DIR"
        log_success "chezmoi installed."
    else
        log_info "chezmoi already installed."
    fi
    
    # 3. Run chezmoi
    log_info "Initializing dotfiles repository from branch '$DOTFILES_BRANCH'..."
    "$CHEZMOI_INSTALL_DIR/chezmoi" init --apply --branch "$DOTFILES_BRANCH" https://github.com/Clay10J/dotfiles.git

    CHEZMOI_SOURCE_DIR=$("$CHEZMOI_INSTALL_DIR/chezmoi" source-path)
    if [ -d "$CHEZMOI_SOURCE_DIR/.chezmoiscripts" ]; then
        log_info "Making chezmoi scripts executable..."
        find "$CHEZMOI_SOURCE_DIR/.chezmoiscripts" -type f -name "*.sh.tmpl" -exec chmod +x {} +
    fi

    log_info "Running a second apply to render templates with newly created secrets..."
    "$CHEZMOI_INSTALL_DIR/chezmoi" apply

    log_success "Bootstrap complete! 🎉"
    log_info "Next steps:"
    log_info "  1. Restart your terminal or log out/in to use the new shell."
    log_info "  2. Sign in to 1Password if prompted."
    log_info "  3. Run 'chezmoi diff' to see any pending changes."
}

main "$@" 