#! /usr/bin/env bash
set -euo pipefail

# 1) Install core packages
if   command -v apt    &>/dev/null; then
  sudo apt update
  sudo apt install -y \
    git curl zsh fzf htop python3-pip nodejs npm build-essential
elif command -v dnf    &>/dev/null; then
  sudo dnf install -y \
    git curl zsh fzf htop python3-pip nodejs npm @development-tools
elif command -v pacman &>/dev/null; then
  sudo pacman -Sy --noconfirm \
    git curl zsh fzf htop python-pip nodejs npm base-devel
else
  echo "Install git, curl, zsh, fzf, htop, python3-pip, nodejs, npm manually." >&2
  exit 1
fi

# 2) Ensure local bin on PATH
export PATH="$HOME/.local/bin:$PATH"

# 3) Install chezmoi
if ! command -v chezmoi &>/dev/null; then
  curl -fsLS get.chezmoi.io | sh -s -- -b "$HOME/.local/bin"
fi

# 4) Install Astral UV
if [ ! -x "$HOME/.local/bin/uv" ]; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 5) Bootstrap Python via UV
if [ ! -d "$HOME/.local/share/uv/python/3.12" ]; then
  uv python install 3.12
fi

# 6) Clone & apply your chezmoi repo (runs run-once scripts too)
chezmoi init --apply git@github.com:Clay10J/dotfiles.git

echo "✅ Bootstrap complete! Open a new shell (e.g. 'zsh')."
