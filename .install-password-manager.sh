#!/usr/bin/env sh
set -eu

# If 1Password CLI already installed, nothing to do
command -v op >/dev/null 2>&1 && exit 0

# Install op based on OS
case "$(uname -s)" in
  Linux)
    sudo apt-get update
    sudo apt-get install -y 1password-cli
    ;;
  *)
    echo "Unsupported OS for 1Password CLI installer" >&2
    exit 1
    ;;
esac
