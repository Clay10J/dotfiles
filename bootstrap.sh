#!/usr/bin/env sh
set -eu

STATE_DIR="$HOME/.local/share/chezmoi"

# 0) Nuke any half-baked state so init always sees an empty dir
rm -rf "$STATE_DIR"

# 1) Install/update the chezmoi binary
sh -c "$(curl -fsSL get.chezmoi.io)"

# 2) Clone your dotfiles (no apply yet)
chezmoi init git@github.com:Clay10J/dotfiles.git

# 3) Install the pre-read hook (now that the dir exists)
curl -fsSL \
  https://raw.githubusercontent.com/Clay10J/dotfiles/main/.install-password-manager.sh \
  -o "$STATE_DIR/.install-password-manager.sh"
chmod +x "$STATE_DIR/.install-password-manager.sh"

# 4) Finally apply everything (the hook will run pre-read)
chezmoi apply

# 5) Ensure zsh is your login shell
if command -v zsh >/dev/null 2>&1; then
  CURRENT_SHELL=$(getent passwd "$(whoami)" | cut -d: -f7)
  ZSH_PATH=$(command -v zsh)
  if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell to Zsh ($ZSH_PATH)…"
    chsh -s "$ZSH_PATH" "$(whoami)" || true
  else
    echo "Login shell already set to Zsh."
  fi
fi
