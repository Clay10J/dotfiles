# dotfiles

This repository contains your personal dotfiles managed by [chezmoi](https://www.chezmoi.io).

## Bootstrapping

On any fresh Linux Mint (or other Linux) host, run:

```bash
curl -fsSL https://raw.githubusercontent.com/you/dotfiles/main/bootstrap.sh | bash
```

This will install or update chezmoi, 1Password CLI, clone/apply your dotfiles, generate SSH keys, install packages, and configure your shell.

## Host-specific configuration

- To enable GUI package installs, set `data.hasGUI = true` under `[data]` in `chezmoi.toml`.
