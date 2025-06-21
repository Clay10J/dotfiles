# Dotfiles

A robust, automated dotfiles setup for Linux using `chezmoi`. This setup provides a modern development environment with minimal configuration.

## Features

- **Automated setup** - One command bootstrap process
- **Modern tools** - Starship prompt, zoxide, fzf, ripgrep, bat, fd
- **Git integration** - Comprehensive Git aliases and configuration
- **1Password integration** - Secure secret management
- **Font management** - Automatic installation of programming fonts
- **Zsh enhancements** - Syntax highlighting and autosuggestions

## Quick Start

### 1. Bootstrap Installation

Run this command on a fresh Linux system:

```bash
curl -fsSL https://raw.githubusercontent.com/Clay10J/dotfiles/main/bootstrap.sh | bash
```

This will:

- Install essential tools (git, curl, gpg, 1password-cli)
- Install chezmoi
- Initialize and apply the dotfiles configuration

### 2. First-Time Setup

On first run, you'll be prompted to:

- Sign in to 1Password (email and account UUID)
- Provide your Git name and email (if different from 1Password email)

### 3. Manual Steps

After the automated setup, you may want to:

#### Install Cursor Editor

Since Cursor doesn't have a public package, install it manually:

1. Download from [cursor.sh](https://cursor.sh)
2. Install the `.deb` package
3. Update your terminal preferences to use one of the installed fonts:
   - MapleMono NF
   - CaskaydiaCove Nerd Font
   - Iosevka Nerd Font

#### Set Default Shell

If zsh isn't your default shell after setup:

```bash
chsh -s /bin/zsh
```

#### Configure Terminal Font

In your terminal preferences, set the font to one of:

- `MapleMono NF`
- `CaskaydiaCove Nerd Font`
- `Iosevka Nerd Font`

## What Gets Installed

### Core Tools

- **fd** - Fast file finder
- **fzf** - Fuzzy finder
- **ripgrep** - Fast grep replacement
- **bat** - Better cat with syntax highlighting
- **zoxide** - Smart cd replacement
- **starship** - Fast, customizable prompt
- **zsh** - Enhanced shell
- **vim** - Text editor
- **unzip** - Archive extraction

### GUI Applications (non-headless only)

- **Brave Browser** - Privacy-focused browser

### External Tools

- **uv** - Fast Python package manager by Astral
- **1Password CLI** - Password and secret management

### Fonts

- **MapleMono NF** - Beautiful programming font
- **CaskaydiaCove Nerd Font** - Microsoft's Cascadia Code with icons
- **Iosevka** - Highly customizable programming font

## Configuration Files

- **`.zshrc`** - Shell configuration with aliases and tool setup
- **`.gitconfig`** - Git configuration with useful defaults
- **`starship.toml`** - Prompt configuration
- **Zsh plugins** - Syntax highlighting and autosuggestions

## Git Aliases

The setup includes comprehensive Git aliases:

```bash
# Basic operations
g    = git
ga   = git add
gc   = git commit -v
gp   = git push
gl   = git pull
gst  = git status

# Branch operations
gco  = git checkout
gcb  = git checkout -b
gsw  = git switch
gswc = git switch -c

# History and diffs
gd   = git diff
glog = git log --oneline --decorate --graph
glola = git log --graph --pretty=format:'...' --abbrev-commit --all

# Stashing
gsta = git stash push
gstl = git stash list
gstp = git stash pop

# And many more...
```

## System Aliases

Useful system aliases:

```bash
# Navigation
..   = cd ..
...  = cd ../..
~    = cd ~

# Enhanced listing
l    = ls -CF
lh   = ls -lh
lt   = ls -lt

# System updates
updateit = sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Quick edits
zshrc = cursor ~/.zshrc
zshrcs = source ~/.zshrc
```

## Architecture

This setup follows a clean architecture:

1. **`bootstrap.sh`** - Minimal script that installs chezmoi
2. **`chezmoi` scripts** - Handle all installation and configuration
3. **Template files** - Configuration files with template variables
4. **Secret management** - 1Password integration for sensitive data

### Scripts (run once)

- `run_once_signin_1password.sh` - 1Password authentication
- `run_once_install_packages.sh` - Package installation
- `run_once_install_uv.sh` - UV installation
- `run_once_setup_shell.sh` - Set zsh as default
- `run_once_install_fonts.sh` - Font installation
- `run_once_install_zsh_plugins.sh` - Zsh plugin installation

## Customization

### Adding Packages

Edit `home/.chezmoidata/packages.yaml` to add/remove packages.

### Modifying Configuration

- Shell config: `home/dot_zshrc.tmpl`
- Git config: `home/dot_gitconfig.tmpl`
- Starship config: `home/dot_config/starship.toml.tmpl`

### Adding Secrets

Use chezmoi's secret management:

```bash
chezmoi add-templated-secret <name>
```

## Troubleshooting

### Fonts Not Showing

1. Restart your terminal
2. Check terminal font settings
3. Run `fc-cache -fv` to refresh font cache

### 1Password Issues

1. Ensure you're signed in: `op account list`
2. Check account configuration in `home/.chezmoi.toml.tmpl`

### Zsh Not Default

```bash
chsh -s /bin/zsh
```

## Maintenance

### Updating

```bash
chezmoi update
chezmoi apply
```

### Adding New Machines

1. Run the bootstrap script
2. Provide 1Password credentials when prompted
3. Set up any machine-specific configurations

## License

This project is open source and available under the [MIT License](LICENSE).
