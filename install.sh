#!/usr/bin/env bash
# install.sh — deploy dotfiles on a new machine
set -e

echo "==> Installing packages..."
paru -S --needed \
  waybar mako fuzzel foot cliphist wl-clipboard \
  hyprlock hypridle awww waypaper swayosd \
  tokyonight-gtk-theme-git darkly qt6ct qt5ct \
  ttf-jetbrains-mono-nerd starship pacman-contrib \
  libnotify playerctl xdg-desktop-portal-gtk \
  gtk-engine-murrine stow

echo "==> Backing up existing configs..."
for dir in waybar mako fuzzel foot hypr niri waypaper swayosd \
  gtk-3.0 gtk-4.0 fontconfig qt6ct qt5ct environment.d \
  colors zathura fish templates; do
  [ -d ~/.config/$dir ] && mv ~/.config/$dir ~/.config/$dir.bak &&
    echo "  backed up ~/.config/$dir"
done
[ -f ~/.config/starship.toml ] && mv ~/.config/starship.toml ~/.config/starship.toml.bak &&
  echo "  backed up ~/.config/starship.toml"

echo "==> Stowing dotfiles..."
cd "$(dirname "$0")"
stow . --target="$HOME"

echo "==> Fixing script permissions..."
chmod +x ~/.config/niri/scripts/*.sh ~/.config/niri/scripts/*.fish

echo "==> Generating colors..."
~/.config/niri/scripts/generate-colors.sh

echo "==> Applying GTK theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Storm-BL'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface font-name 'Google Sans Flex 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'

echo "==> Adding starship to fish..."
grep -q 'starship init fish' ~/.config/fish/config.fish 2>/dev/null ||
  echo 'starship init fish | source' >>~/.config/fish/config.fish

echo ""
echo "Done. Log out and back in for all changes to take effect."
echo "Don't forget to install Google Sans Flex manually from fonts.google.com"
