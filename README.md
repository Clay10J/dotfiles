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

### 1. 1Password CLI Installation

You must install and sign in to the 1Password CLI before running the bootstrap script. Follow the instructions for your platform:

### Debian/Ubuntu

```sh
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update && sudo apt install 1password-cli
```

### Fedora

```sh
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo tee /etc/yum.repos.d/1password.repo <<EOF
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
sudo dnf install 1password-cli
```

### Arch Linux

```sh
yay -S 1password-cli
# or
paru -S 1password-cli
```

### macOS (Homebrew)

```sh
brew install --cask 1password/tap/1password-cli
```

### Windows (winget)

```powershell
winget install --id=AgileBits.1Password.CLI
```

After installing, sign in to 1Password CLI:

```sh
eval $(op signin)
```

If you are not signed in, the bootstrap script will exit with an error.

### 2. SSH Key Setup

**Before running the bootstrap script**, you need to create SSH keys in 1Password:

1. **Sign in to 1Password CLI** (if not already signed in):

   ```sh
   eval $(op signin)
   ```

2. **Create a new SSH Key item** in your Personal vault:

   ```sh
   op item create --vault Personal --category "SSH Key" --title "[hostname] SSH Key"
   ```

   Replace `[hostname]` with your actual hostname (e.g., "commander SSH Key").

3. **Generate a new SSH key pair** using 1Password's built-in generator:

   ```sh
   op item edit "[hostname] SSH Key" --generate-password
   ```

4. **Copy the public key** and add it to GitHub/GitLab/etc.:

   ```sh
   op item get "[hostname] SSH Key" --fields public_key
   ```

### 3. Bootstrap Installation

**Prerequisite**: Ensure `curl` is installed on your system. On most Linux distributions, it's available by default, but if not:

```bash
sudo apt update && sudo apt install curl
```

Then run this command on a fresh Linux system:

```bash
curl -fsSL https://raw.githubusercontent.com/Clay10J/dotfiles/main/bootstrap.sh | bash
```

This will:

- Install essential tools (git, curl, gpg)
- Install chezmoi
- Initialize and apply the dotfiles configuration
- Create SSH files from your 1Password keys

### 4. First-Time Setup

On first run, you'll be prompted to:

- Sign in to 1Password (email and account UUID)
- Provide your Git name and email (if different from 1Password email)

### 5. Manual Steps

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
- Starship config: `
