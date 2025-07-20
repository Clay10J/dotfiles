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

You must install the 1Password CLI before running the bootstrap script. Follow the instructions for your platform:

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

---

**After installing the 1Password CLI, you must add your account and sign in (all platforms):**

```sh
op account add
eval $(op signin)
```

If you are not signed in, the bootstrap script will exit with an error.

### 2. SSH Key Setup

**After signing in to 1Password CLI**, create SSH keys in 1Password:

1. **Create a new SSH Key item** in your Personal vault:

   ```sh
   op item create --vault Personal --category "SSH Key" --title "[hostname] SSH Key"
   ```

   Replace `[hostname]` with your actual hostname (e.g., "commander SSH Key").

2. **Copy the public key** and add it to GitHub/GitLab/etc.:

   ```sh
   op item get "[hostname] SSH Key" --fields public_key
   ```

3. **Add the public key to servers** for SSH access:

   ```sh
   # Get the public key
   op item get "[hostname] SSH Key" --fields public_key

   # Add to server's authorized_keys (replace with your server details)
   ssh user@server "echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@hostname' >> ~/.ssh/authorized_keys"
   ```

**Note:** This setup uses 1Password SSH agent integration. SSH keys are stored securely in 1Password and served via the SSH agent at `~/.1password/agent.sock`. No SSH key files are stored on disk.

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

- Install essential tools (git, gpg)
- Install chezmoi
- Initialize and apply the dotfiles configuration
- Create SSH files from your 1Password keys

### 4. Manual Steps

After the automated setup, you may want to:

#### Install Cursor Editor

Since Cursor doesn't have a public package, install it manually:

1. **For automated installation with auto-updates**: Follow the [complete Cursor installation guide](CURSOR_INSTALL.md) which includes cleanup, installation, and systemd-based auto-updates.

2. **For manual installation**: Download from [cursor.sh](https://cursor.sh) and install the `.deb` package.

3. Update your terminal preferences to use one of the installed fonts:
   - MapleMono NF
   - CaskaydiaCove Nerd Font
   - Iosevka Nerd Font

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
- **1Password** - Password manager GUI

### External Tools

- **uv** - Fast Python package manager by Astral
- **1Password CLI** - Password and secret management (manual installation)

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

- `run_once_install_packages.sh` - Package installation
- `run_once_install_uv.sh` - UV installation
- `run_once_setup_shell.sh` - Set zsh as default
- `run_once_install_fonts.sh` - Font installation
- `run_once_install_zsh_plugins.sh` - Zsh plugin installation
- `run_once_setup_ssh_agent.sh` - Configure 1Password SSH agent

## Customization

### Adding Packages

Edit `home/.chezmoidata/packages.yaml` to add/remove packages.

### Modifying Configuration

- Shell config: `home/dot_zshrc.tmpl`
- Git config: `home/dot_gitconfig.tmpl`
- Starship config: `home/dot_config/starship.toml.tmpl`

### Customizing Your Git Identity

By default, chezmoi uses values from `home/.chezmoidata/chezmoi.yaml` for your Git name and email:

```yaml
git_name: "Your Name"
git_email: "your@email.com"
```

- `git_name` should be your real name or the name you want to appear in your Git commit history.
- `git_email` should be the email address you use for your Git hosting account (e.g., GitHub, GitLab).

To override these for a specific machine, create a file named `home/.chezmoidata/chezmoi.<hostname>.yaml` (replace `<hostname>` with the output of `hostname` on that machine):

```yaml
git_name: "Work Laptop Name"
git_email: "work@email.com"
```

Chezmoi will automatically use the host-specific values if they exist.

## Host-Specific Overrides and Data Files

Chezmoi supports host-specific configuration using files like `.chezmoidata/chezmoi.<hostname>.yaml`. These files allow you to set variables (e.g., `headless: true`, `work: false`) that are only used on a specific machine.

### Should you commit host override files?

- **If they only contain non-sensitive, non-secret config:** Yes, commit them. This enables fully automated bootstrapping on new machines.
- **If they contain secrets or private data:** Do NOT commit them. Add them to `.gitignore`.

### How it works

- When you run the bootstrap script, chezmoi will automatically use the file matching the current hostname (e.g., `.chezmoidata/chezmoi.dot-VirtualBox.yaml`).
- This allows you to have per-host settings without manual intervention.

### Example

```yaml
# .chezmoidata/chezmoi.dot-VirtualBox.yaml
headless: true
work: false
```

### Best Practices

- Only commit host files if they do not contain secrets.
- For secrets, use a separate `.private.yaml` file and add it to `.gitignore`.
- Document your approach in the README for clarity.

## SSH Configuration

### Host Profiles

The setup uses different profiles for different types of hosts:

- **Client workstations** (`sshAgent: true`): Get SSH config with 1Password agent integration
- **Servers** (`sshAgent: false`): No SSH config, just terminal settings

### SSH Agent Integration

Client workstations automatically configure:

- SSH agent using 1Password (`~/.1password/agent.sock`)
- SSH config with host-specific entries
- Environment variable `SSH_AUTH_SOCK`

### Host-Specific SSH Configuration

Each host can define:

- `sshAgent`: Whether to use SSH agent (true for workstations, false for servers)
- `sshUser`: SSH username for the host
- `sshHostName`: Hostname or IP for SSH connection
- `terminalType`: Terminal type for proper key mapping

## DNS Configuration

Add local DNS entries through Pi-hole admin → Local DNS → DNS Records.

> **Note**: When adding new hosts to your SSH configuration, remember to add their hostnames to Pi-hole DNS as well.

Reference: [Pi-hole Local DNS Documentation](https://docs.pi-hole.net/guides/dns/unbound/)

> **Note**: If you set up a reverse proxy, you may need to change the SSH hostname in `.chezmoidata/chezmoi.pihole.yaml` to avoid conflicts between web and SSH traffic.
