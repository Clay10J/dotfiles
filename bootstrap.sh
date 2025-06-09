# fetch the pre-read hook from your GitHub dotfiles repo
mkdir -p ~/.local/share/chezmoi
curl -fsSL \
  https://raw.githubusercontent.com/Clay10J/dotfiles/main/.install-password-manager.sh \
  -o ~/.local/share/chezmoi/.install-password-manager.sh
chmod +x ~/.local/share/chezmoi/.install-password-manager.sh

# now run chezmoi as usual
chezmoi init --apply git@github.com:Clay10J/dotfiles.git
