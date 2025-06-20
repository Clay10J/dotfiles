# Dotfiles

Your personal dotfiles managed by [chezmoi](https://www.chezmoi.io) with automated bootstrap for Linux Mint systems.

## Quick Start (Brand New System)

On any fresh Linux Mint laptop or VM, run:

```bash
curl -fsSL https://raw.githubusercontent.com/Clay10J/dotfiles/main/bootstrap.sh | bash
```

This will:

1. Install essential dependencies (curl, git, yq)
2. Install chezmoi CLI in `~/.local/bin`
3. Clone and apply your dotfiles
4. Set up third-party repositories (Brave Browser, 1Password)
5. Install all packages declaratively from `packages.yaml`
6. Sign into 1Password CLI
7. Generate unique SSH keys and store them in 1Password
8. Install additional tools that require custom installation:
   - **starship** - Fast, customizable prompt
   - **uv** - Fast Python package manager
   - **kitty** - GPU-accelerated terminal
   - **Custom fonts** - MapleMono NF, CaskaydiaCove Nerd Font, Iosevka
9. Set zsh as your default shell

## What Gets Installed

### CLI Tools (via apt)

- **zsh** - Better shell with plugins
- **fzf** - Fuzzy finder
- **zoxide** - Smarter cd command
- **ripgrep** - Fast grep alternative
- **bat** - Better cat with syntax highlighting
- **fd-find** - Fast find alternative
- **htop** - Process viewer
- **tree** - Directory tree viewer
- **jq** - JSON processor
- **curl/wget** - HTTP clients
- **git** - Version control
- **unzip** - Archive utility
- **1password-cli** - 1Password command line tool

### GUI Tools (via apt, if system has GUI)

- **Brave Browser** - Privacy-focused browser
- **VLC** - Media player
- **gnome-terminal** - Terminal emulator
- **1password** - 1Password GUI application

### Custom Installations

- **starship** - Fast, customizable prompt
- **uv** - Fast Python package manager
- **kitty** - GPU-accelerated terminal emulator
- **Custom fonts** - MapleMono NF, CaskaydiaCove Nerd Font, Iosevka

### Configuration

- SSH keys automatically generated and stored in 1Password
- Starship prompt configured with git status, Python/Node/Rust version info
- Zsh configured with useful aliases and completions
- 1Password integration for secure credential management

## Package Management

The system uses a hybrid approach:

### Declarative Packages (`packages.yaml`)

- Standard packages available in Ubuntu/Debian repositories
- Third-party packages from added repositories (Brave, 1Password)
- Automatically installed via `apt`

### Custom Install Scripts

- Tools not available in package managers
- Require special installation methods
- Located in `.chezmoiscripts/`

## Repository Structure

```
.
├── .chezmoiroot           # contains "home" (sets source state root)
├── bootstrap.sh           # One-command installer for new systems
├── README.md
└── home/                  # chezmoi source state
    ├── .chezmoi.toml.tmpl # chezmoi configuration with execution order
    ├── .chezmoidata/      # declarative data
    │   ├── packages.yaml  # package lists (CLI/GUI)
    │   └── hostdata.yaml  # host-specific settings
    ├── .chezmoiscripts/   # installation scripts
    │   ├── run_once_setup_repositories.sh.tmpl    # Repository setup
    │   ├── run_once_install_packages.sh.tmpl      # Package installation
    │   ├── run_once_signin_1password.sh.tmpl      # 1Password auth
    │   ├── run_once_generate_ssh_key.sh.tmpl      # SSH key generation
    │   └── ...            # Other custom installations
    ├── .zshrc.tmpl        # shell configuration
    ├── .config/starship.toml.tmpl # prompt configuration
    └── .ssh/config.tmpl   # SSH configuration
```

## Execution Order

Scripts run in this specific order to ensure dependencies are met:

1. **Repository Setup** - Add Brave and 1Password repositories
2. **Package Installation** - Install all packages from `packages.yaml`
3. **1Password Sign-in** - Authenticate with 1Password CLI
4. **SSH Key Generation** - Create and store SSH keys in 1Password
5. **Custom Installations** - Install tools requiring special methods
6. **Configuration** - Set up shell, permissions, etc.

## Error Handling

The system provides clear, actionable error messages:

- **❌ Failures** - Scripts exit with non-zero codes and detailed error messages
- **✅ Successes** - Clear confirmation of completed operations
- **⚠️ Warnings** - Non-critical issues that don't stop execution
- **🔍 Verification** - Critical packages are verified after installation

## Adding New Hosts

1. Create a new entry in `home/.chezmoidata/hostdata.yaml`:

   ```yaml
   new-hostname:
     headless: false # true for servers/VMs without GUI
     username: "clay"
     email: "clay@example.com"
     sshAgent: true
     sshUser: "clay"
   ```

2. Add host-specific chezmoi config in `home/.chezmoi.toml.tmpl`:

   ```toml
   [host."new-hostname"]
   sshAgent = true
   sshUser = "clay"
   ```

3. Run the bootstrap script on the new host.

**Note**: OS and distribution are automatically detected by chezmoi using built-in variables like `{{ .chezmoi.os }}` and `{{ .chezmoi.distro }}`.

## Manual Commands

After bootstrap, you can use these chezmoi commands:

```bash
# Check what would be changed
chezmoi diff

# Apply changes
chezmoi apply

# See what's managed
chezmoi status

# Edit a template
chezmoi edit ~/.zshrc
```

## SSH Key Management

SSH keys are automatically:

- Generated with unique names per host (`$(hostname) SSH Key`)
- Stored securely in 1Password
- Configured with proper permissions
- Added to SSH agent

Each host gets its own key named `$(hostname) SSH Key` in 1Password.

## 1Password Integration

The system integrates with 1Password for:

- **SSH Key Storage** - Keys are generated and stored securely
- **Credential Management** - CLI and GUI tools are installed
- **Authentication** - Automatic sign-in during bootstrap

## Troubleshooting

### Common Issues

1. **1Password Sign-in Fails**

   - Ensure you have valid 1Password credentials
   - Check that 1Password CLI installed correctly

2. **Package Installation Fails**

   - Check internet connectivity
   - Verify repository setup completed successfully
   - Look for specific error messages in output

3. **SSH Key Generation Fails**
   - Ensure 1Password sign-in completed first
   - Check that you have permission to create items in 1Password

### Debug Mode

Run with verbose output to see detailed progress:

```bash
chezmoi apply --verbose
```

---

This setup prioritizes simplicity, reliability, and clear error reporting. Everything is version-controlled and can be easily extended for new hosts or tools.
