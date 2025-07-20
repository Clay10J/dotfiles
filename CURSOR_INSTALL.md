# Installing & Auto-Updating Cursor on Linux

This guide provides a complete setup for installing Cursor editor on Linux with automatic updates via systemd user timers.

## Cleanup

Before installing, remove any existing Cursor installations:

```bash
# Stop and disable any existing timers/services
systemctl --user stop cursor-update.timer 2>/dev/null || true
systemctl --user disable cursor-update.timer 2>/dev/null || true
systemctl --user stop cursor-update.service 2>/dev/null || true

# Remove old AppImages and symlinks
rm -f ~/.local/bin/cursor.AppImage
rm -f ~/.local/bin/cursor
rm -f ~/.local/bin/Cursor.AppImage
rm -f ~/.local/bin/Cursor

# Remove old desktop entries and icons
rm -f ~/.local/share/applications/cursor.desktop
rm -f ~/.local/share/applications/Cursor.desktop
rm -f ~/.local/share/icons/cursor-icon.png
rm -f ~/.local/share/icons/cursor.png

# Remove old systemd files
rm -f ~/.config/systemd/user/cursor-update.service
rm -f ~/.config/systemd/user/cursor-update.timer

# Remove old update scripts
rm -f ~/.local/bin/update-cursor.sh
```

## Installation

### 1. Create Required Directories

```bash
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/icons
mkdir -p ~/.local/share/applications
mkdir -p ~/.config/systemd/user
```

### 2. Download and Install Cursor

```bash
# Get the download URL from Cursor's API
DOWNLOAD_URL=$(curl -s https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable | jq -r '.downloadUrl')

# Download the AppImage
curl -L "$DOWNLOAD_URL" -o ~/.local/bin/cursor.AppImage

# Make executable and create symlink
chmod +x ~/.local/bin/cursor.AppImage
ln -sf ~/.local/bin/cursor.AppImage ~/.local/bin/cursor
```

### 3. Download Icon

```bash
# Download the official Cursor icon
curl -L https://cursor.sh/icon.png -o ~/.local/share/icons/cursor-icon.png
```

### 4. Create Desktop Entry

Create `~/.local/share/applications/cursor.desktop`:

```ini
[Desktop Entry]
Name=Cursor
Comment=AI-first code editor
Exec=cursor --no-sandbox %F
Icon=cursor-icon
Type=Application
Categories=Development;IDE;TextEditor;
MimeType=text/plain;inode/directory;application/x-code-workspace;
StartupWMClass=Cursor
```

## Auto-Update Setup

### 1. Create Update Script

Create `~/.local/bin/update-cursor.sh`:

```bash
#!/bin/bash

# Exit on any error
set -e

# Get current version
CURRENT_VERSION=$(~/.local/bin/cursor.AppImage --version 2>/dev/null || echo "unknown")

# Get latest version info
LATEST_INFO=$(curl -s https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable)
LATEST_VERSION=$(echo "$LATEST_INFO" | jq -r '.version')
DOWNLOAD_URL=$(echo "$LATEST_INFO" | jq -r '.downloadUrl')

echo "Current version: $CURRENT_VERSION"
echo "Latest version: $LATEST_VERSION"

# Check if update is needed
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Updating Cursor to version $LATEST_VERSION..."

    # Download new version
    curl -L "$DOWNLOAD_URL" -o ~/.local/bin/cursor.AppImage.new

    # Verify download (basic check)
    if [ -f ~/.local/bin/cursor.AppImage.new ]; then
        chmod +x ~/.local/bin/cursor.AppImage.new

        # Replace old version
        mv ~/.local/bin/cursor.AppImage.new ~/.local/bin/cursor.AppImage

        echo "Cursor updated successfully to version $LATEST_VERSION"
    else
        echo "Failed to download new version"
        exit 1
    fi
else
    echo "Cursor is already up to date"
fi
```

Make it executable:

```bash
chmod +x ~/.local/bin/update-cursor.sh
```

### 2. Create Systemd Service

Create `~/.config/systemd/user/cursor-update.service`:

```ini
[Unit]
Description=Update Cursor Editor
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=%h/.local/bin/update-cursor.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

### 3. Create Systemd Timer

Create `~/.config/systemd/user/cursor-update.timer`:

```ini
[Unit]
Description=Update Cursor Editor daily
Requires=cursor-update.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=3600

[Install]
WantedBy=timers.target
```

### 4. Enable Auto-Updates

```bash
# Reload systemd user configuration
systemctl --user daemon-reload

# Enable and start the timer
systemctl --user enable cursor-update.timer
systemctl --user start cursor-update.timer

# Verify timer is active
systemctl --user status cursor-update.timer
```

## Verification & Troubleshooting

### Test Installation

```bash
# Launch Cursor
cursor --no-sandbox

# Check version
~/.local/bin/cursor.AppImage --version

# Test manual update
~/.local/bin/update-cursor.sh
```

### Check Auto-Update Status

```bash
# Check timer status
systemctl --user status cursor-update.timer

# View update logs
journalctl --user -u cursor-update.service

# Check when timer will next run
systemctl --user list-timers cursor-update.timer
```

### Customize Update Schedule

To change the update frequency, edit `~/.config/systemd/user/cursor-update.timer`:

```ini
# Daily at 2 AM
OnCalendar=02:00

# Weekly on Sundays at 3 AM
OnCalendar=weekly

# Every 6 hours
OnCalendar=*-*-* 00,06,12,18:00:00
```

After changing the timer, reload and restart:

```bash
systemctl --user daemon-reload
systemctl --user restart cursor-update.timer
```

### Remove Sandbox Flag (Optional)

If you want to remove the `--no-sandbox` flag from the desktop entry:

```bash
# Edit the desktop file
sed -i 's/Exec=cursor --no-sandbox %F/Exec=cursor %F/' ~/.local/share/applications/cursor.desktop
```

**Note**: The `--no-sandbox` flag is often required on Linux systems where AppImages don't have proper sandboxing support.

### Troubleshooting

#### Timer Not Running

```bash
# Check if timer is enabled
systemctl --user is-enabled cursor-update.timer

# Check timer configuration
systemctl --user cat cursor-update.timer

# Manually trigger an update
systemctl --user start cursor-update.service
```

#### Permission Issues

```bash
# Ensure AppImage is executable
chmod +x ~/.local/bin/cursor.AppImage

# Check file permissions
ls -la ~/.local/bin/cursor*
```

#### Network Issues

The service waits for `network-online.target`. If you have network issues:

```bash
# Check network status
systemctl --user status network-online.target

# Test connectivity
curl -s https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable
```

## Integration with Your Dotfiles

To integrate this with your chezmoi dotfiles setup, you can add these files to your template structure:

- `~/.local/bin/update-cursor.sh` → `home/local_bin_update-cursor.sh.tmpl`
- `~/.config/systemd/user/cursor-update.service` → `home/config_systemd_user_cursor-update.service.tmpl`
- `~/.config/systemd/user/cursor-update.timer` → `home/config_systemd_user_cursor-update.timer.tmpl`
- `~/.local/share/applications/cursor.desktop` → `home/local_share_applications_cursor.desktop.tmpl`

This ensures Cursor is automatically installed and configured on new machines when you run your bootstrap script.
