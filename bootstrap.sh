#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root. Please run as a regular user."
   exit 1
fi

log_info "Starting dotfiles bootstrap for $(hostname)..."

# 1) Ensure essential directories exist
CHEZMOI_INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$CHEZMOI_INSTALL_DIR"
export PATH="$CHEZMOI_INSTALL_DIR:$PATH"

# 2) Check for essential system tools
log_info "Checking system dependencies..."
MISSING_DEPS=()

if ! command -v curl >/dev/null 2>&1; then
    MISSING_DEPS+=("curl")
fi

if ! command -v git >/dev/null 2>&1; then
    MISSING_DEPS+=("git")
fi

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    log_warning "Missing dependencies: ${MISSING_DEPS[*]}"
    log_info "Installing missing dependencies..."
    sudo apt-get update
    sudo apt-get install -y "${MISSING_DEPS[@]}"
fi

# 3) Install yq if not available
if ! command -v yq >/dev/null 2>&1; then
    log_info "Installing yq..."
    YQ_VERSION="v4.45.4"
    YQ_BINARY="yq_linux_amd64"
    
    # Download yq
    if curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -o "/tmp/${YQ_BINARY}"; then
        # Make it executable and move to local bin
        chmod +x "/tmp/${YQ_BINARY}"
        mv "/tmp/${YQ_BINARY}" "$CHEZMOI_INSTALL_DIR/yq"
        log_success "yq installed successfully"
    else
        log_error "Failed to download yq"
        exit 1
    fi
else
    log_info "yq already installed"
fi

# 4) Install or update chezmoi
log_info "Installing chezmoi..."
if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$CHEZMOI_INSTALL_DIR"
    log_success "chezmoi installed successfully"
else
    log_info "chezmoi already installed, updating..."
    sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$CHEZMOI_INSTALL_DIR"
    log_success "chezmoi updated successfully"
fi

# 5) Initialize and apply dotfiles
log_info "Initializing dotfiles..."
"$CHEZMOI_INSTALL_DIR/chezmoi" init https://github.com/Clay10J/dotfiles.git

# Run apply twice to handle a "chicken-and-egg" problem in chezmoi's
# order of operations. Templates are rendered *before* scripts are run.
#
# 1. The first `apply` runs scripts that create secrets (e.g., SSH key in 1P).
#    It fails to render templates that need those secrets, but we allow failure.
# 2. The second `apply` re-reads the data (now including the new secrets)
#    and can successfully render all templates.
log_info "Running first apply to execute installation scripts..."
"$CHEZMOI_INSTALL_DIR/chezmoi" apply || true

log_info "Running second apply to render templates with new data..."
"$CHEZMOI_INSTALL_DIR/chezmoi" apply

log_success "Bootstrap complete! 🎉"
log_info "Next steps:"
log_info "1. Open a new terminal to see your new shell"
log_info "2. Run 'chezmoi status' to see what was installed"
log_info "3. Run 'chezmoi diff' to see any pending changes"
log_info "4. Check your SSH keys in 1Password"
