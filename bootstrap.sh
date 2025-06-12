#!/usr/bin/env sh
set -eu

# 0) Make sure ~/bin is on PATH
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# 1) Install/update chezmoi into ~/bin if missing
if ! command -v chezmoi >/dev/null 2>&1; then
  mkdir -p "$HOME/bin"
  sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$HOME/bin"
fi

STATE_DIR="$HOME/.local/share/chezmoi"
REPO="git@github.com:Clay10J/dotfiles.git"
HOOK_URL="https://raw.githubusercontent.com/Clay10J/dotfiles/main/.install-password-manager.sh"

# 2) Clone vs. update
if [ -d "$STATE_DIR/.git" ]; then
  # → Existing install: pull & apply
  # 2a) Ensure hook is installed for any applies needing 1Password
  mkdir -p "$STATE_DIR"
  curl -fsSL "$HOOK_URL" -o "$STATE_DIR/.install-password-manager.sh"
  chmod +x "$STATE_DIR/.install-password-manager.sh"

  # 2b) Pull downstream changes and re-apply
  chezmoi update
  chezmoi apply
else
  # → Fresh install: clone first (no --apply), then hook, then apply
  rm -rf "$STATE_DIR"
  chezmoi init "$REPO"

  mkdir -p "$STATE_DIR"
  curl -fsSL "$HOOK_URL" -o "$STATE_DIR/.install-password-manager.sh"
  chmod +x "$STATE_DIR/.install-password-manager.sh"

  chezmoi apply
fi

# 3) (Optional) set Zsh as login shell if not already
if command -v zsh >/dev/null 2>&1; then
  USER_SHELL=$(getent passwd "$(whoami)" | cut -d: -f7)
  ZSH_PATH=$(command -v zsh)
  if [ "$USER_SHELL" != "$ZSH_PATH" ]; then
    printf 'Changing login shell to %s…\n' "$ZSH_PATH"
    chsh -s "$ZSH_PATH" "$(whoami)" || true
  fi
fi

echo "✅ Bootstrap complete. Open a new terminal to start using your dotfiles."
