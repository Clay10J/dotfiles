#!/usr/bin/env sh
set -eu

# 0) Ensure ~/bin is on your PATH
export CHEZMOI_INSTALL_DIR="$HOME/bin"
export PATH="$CHEZMOI_INSTALL_DIR:$PATH"

# 1) Install/update chezmoi into ~/bin
if ! command -v chezmoi >/dev/null 2>&1; then
  mkdir -p "$CHEZMOI_INSTALL_DIR"
  sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$CHEZMOI_INSTALL_DIR"
fi

# 2) Install the 1Password pre-read hook
HOOK="$HOME/.config/chezmoi/install-password-manager.sh"
mkdir -p "$(dirname "$HOOK")"
curl -fsSL \
  https://raw.githubusercontent.com/Clay10J/dotfiles/main/.install-password-manager.sh \
  -o "$HOOK"
chmod +x "$HOOK"

# 3) Bootstrap vs. update
STATE_DIR="$HOME/.local/share/chezmoi"
REPO="git@github.com:Clay10J/dotfiles.git"

if [ ! -d "$STATE_DIR/.git" ]; then
  echo "🚀 First-time bootstrap: init & apply templates"
  rm -rf "$STATE_DIR"
  # Clone, render config (incl. scriptsDir), load data & scripts, run hooks, apply templates
  chezmoi init --apply "$REPO"
  
  echo "⚙️  Applying with verbose to show script runs"
  chezmoi apply --verbose
else
  echo "⟳ Existing install: update config & apply templates"
  chezmoi update --init
  chezmoi apply --verbose
fi

# 4) (Optional) Switch your login shell to zsh
if command -v zsh >/dev/null 2>&1; then
  CURRENT="$(getent passwd "$(whoami)" | cut -d: -f7)"
  ZSH="$(command -v zsh)"
  if [ "$CURRENT" != "$ZSH" ]; then
    printf '🔄 Changing login shell to %s…\n' "$ZSH"
    chsh -s "$ZSH" "$(whoami)" || true
  fi
fi

echo "✅ Bootstrap complete. Open a new terminal to see your dotfiles in action."
