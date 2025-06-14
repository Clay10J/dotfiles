# Dotfiles

Your personal dotfiles managed by [chezmoi](https://www.chezmoi.io).

## Repo layout

```text
.
├── .chezmoiroot           # contains "home" (sets source state root)
├── bootstrap.sh           # Day-one installer script
├── README.md
└── home/                  # chezmoi source state
    ├── .config/chezmoi/   # chezmoi CLI config
    │   └── chezmoi.toml.tmpl
    ├── .chezmoidata/      # declarative data (packages + hosts)
    │   ├── packages.yaml
    │   └── hosts/
    │       ├── commander.yaml
    │       └── work-laptop.yaml
    ├── .chezmoiscripts/   # template scripts (run_once_*.sh.tmpl, run_onchange_*.sh.tmpl)
    ├── .chezmoiignore     # ignore support dirs in $HOME (\.chezmoidata, \.chezmoiscripts)
    └── *.tmpl             # other dotfiles (e.g. .zshrc.tmpl)
```

## Bootstrapping

On any fresh Linux Mint laptop or VM, run:

```bash
curl -fsSL https://raw.githubusercontent.com/Clay10J/dotfiles/main/bootstrap.sh | bash
```

This will:

1. Install or update the chezmoi CLI (in `~/.local/bin`).
2. Prompt you to sign into 1Password CLI.
3. Clone and apply your `home/` source state.
4. Generate and add SSH keys to 1Password.
5. Install CLI and, if `hasGUI: true`, GUI packages per host.
6. Install and configure tools (starship, uv, alacritty, etc.).
7. Set your default shell to zsh.

## Per-host overrides

- **Host-specific data** (e.g. `hasGUI`) lives in `.chezmoidata/hosts/<hostname>.yaml`. Do **not** set these data flags in your TOML config.
- **CLI configuration** (e.g. `sshAgent`, `sshUser`) lives in `home/.config/chezmoi/chezmoi.toml.tmpl` under `[host."<hostname>"]` blocks.

## Ignored files

The file `home/.chezmoiignore` prevents support directories (`.chezmoidata/`, `.chezmoiscripts/`) from being written into your `$HOME`.

---

Feel free to customize your package lists, add more hosts, or extend the scripts under `.chezmoiscripts/` as your workflow evolves.

