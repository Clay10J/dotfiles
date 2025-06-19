#!/usr/bin/env bash
set -euo pipefail

# 1) Ensure ~/.local/bin is on your PATH for chezmoi
CHEZMOI_INSTALL_DIR="$HOME/.local/bin"
export PATH="$CHEZMOI_INSTALL_DIR:$PATH"

# 2) Install or update chezmoi
if ! command -v chezmoi >/dev/null 2>&1; then
  mkdir -p "$CHEZMOI_INSTALL_DIR"
  sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$CHEZMOI_INSTALL_DIR"
fi

# 3) Initialize and apply dotfiles
"$CHEZMOI_INSTALL_DIR/chezmoi" init --apply https://github.com/Clay10J/dotfiles.git

echo "✅ Bootstrap complete. Open a new terminal to see your dotfiles."
