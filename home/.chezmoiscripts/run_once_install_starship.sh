#!/usr/bin/env bash
set -euo pipefail

# This script installs Starship using the official installer.
# It's a 'run_once' script because Starship only needs to be installed once.

# —————— COLORS & LOGGING ——————
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'
log_info() { echo -e "\n${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }

# —————— SCRIPT LOGIC ——————
main() {
    if command -v starship >/dev/null 2>&1; then
        log_info "Starship is already installed."
    else
        log_info "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        log_success "Starship installed successfully."
    fi
}

main "$@" 