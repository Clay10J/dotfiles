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
