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

    # 1. Install basic tools needed for repository setup
    log_info "Installing basic tools (git, curl, gpg)..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq git curl gpg
    log_success "Basic tools installed."

    # 2. Add 1Password repository and GPG key
    log_info "Adding 1Password repository and GPG key..."
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    local arch
    case "$(dpkg --print-architecture)" in
        "amd64"|"x86_64") arch="amd64" ;;
        "arm64"|"aarch64") arch="arm64" ;;
        *) log_error "Unsupported architecture for 1Password"; exit 1 ;;
    esac
    echo "deb [arch=${arch} signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/${arch} stable main" | sudo tee /etc/apt/sources.list.d/1password.list > /dev/null

    # 3. Install 1Password CLI
    log_info "Installing 1Password CLI..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq 1password-cli
    log_success "1Password CLI installed."

    # 4. Install chezmoi
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
    
    # 5. Run chezmoi
    log_info "Initializing dotfiles repository from branch '$DOTFILES_BRANCH'..."
    "$CHEZMOI_INSTALL_DIR/chezmoi" init --branch "$DOTFILES_BRANCH" https://github.com/Clay10J/dotfiles.git

    CHEZMOI_SOURCE_DIR=$("$CHEZMOI_INSTALL_DIR/chezmoi" source-path)
    if [ -d "$CHEZMOI_SOURCE_DIR/.chezmoiscripts" ]; then
        log_info "Making chezmoi scripts executable..."
        find "$CHEZMOI_SOURCE_DIR/.chezmoiscripts" -type f -name "*.sh.tmpl" -exec chmod +x {} +
    fi

    log_info "Applying dotfiles... This may take a few minutes."
    log_info "(This first pass runs install scripts and may show 'file does not exist' errors, which is normal.)"
    "$CHEZMOI_INSTALL_DIR/chezmoi" apply || true

    log_info "Running a second apply to render templates with newly created secrets..."
    "$CHEZMOI_INSTALL_DIR/chezmoi" apply

    log_success "Bootstrap complete! 🎉"
    log_info "Next steps:"
    log_info "  1. Restart your terminal or log out/in to use the new shell."
    log_info "  2. Sign in to 1Password if prompted."
    log_info "  3. Run 'chezmoi diff' to see any pending changes."
}

main "$@" 