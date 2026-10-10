#!/usr/bin/env bash
# install.sh — deploy these dotfiles on a fresh CachyOS/Arch box (niri + Quickshell)
# Safe to re-run: packages use --needed, stow is restowed, conflicts are moved aside.
set -euo pipefail

cd "$(dirname "$0")"
warn() { printf '  !! %s\n' "$*" >&2; }

# ── packages ────────────────────────────────────────────────────────────────
# Core: the script aborts if any of these fail.
CORE=(
  niri foot hyprlock awww
  cliphist wl-clipboard libnotify playerctl
  brightnessctl ddcutil wlsunset
  pacman-contrib imagemagick ripgrep fish starship stow
  qt6ct qt5ct darkly adw-gtk-theme
  xdg-desktop-portal-gtk polkit-gnome gtk-engine-murrine
  ttf-jetbrains-mono-nerd
)

# AUR / less common names: tried one by one, a failure only warns.
# Verify these names on your system (paru -Ss <name>) before relying on them.
OPTIONAL=(
  noctalia-qs # Quickshell fork the shell runs on (or plain `quickshell`)
  wlctl       # Wi-Fi TUI opened by right-click on the Wi-Fi tile
  bluetui     # Bluetooth TUI opened by right-click on the Bluetooth tile
)

echo "==> Installing core packages..."
paru -S --needed "${CORE[@]}"

echo "==> Installing optional packages..."
for pkg in "${OPTIONAL[@]}"; do
  paru -S --needed "$pkg" || warn "could not install $pkg, install it manually"
done

# ── stow ────────────────────────────────────────────────────────────────────
echo "==> Checking for stow conflicts..."
conflicts=$(stow -n . --target="$HOME" 2>&1 |
  sed -n 's/.*existing target is not owned by stow: //p;s/.*existing target is neither a link nor a directory: //p' |
  sort -u || true)

if [ -n "$conflicts" ]; then
  echo "  moving conflicting files aside (*.bak):"
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    target="$HOME/$rel"
    if [ -e "$target" ] || [ -L "$target" ]; then
      mv "$target" "$target.bak"
      echo "    $target -> $target.bak"
    fi
  done <<<"$conflicts"
fi

echo "==> Stowing dotfiles..."
stow -R . --target="$HOME"

echo "==> Fixing script permissions..."
chmod +x ~/.config/niri/scripts/*.sh ~/.config/niri/scripts/*.fish

# ── runtime dirs the shell and scripts expect ───────────────────────────────
echo "==> Creating runtime directories..."
mkdir -p ~/Pictures/wallpapers ~/.local/state/qs-test ~/.cache/qs-test

# ── theme ───────────────────────────────────────────────────────────────────
echo "==> Generating colors..."
~/.config/niri/scripts/generate-colors.sh

echo "==> Applying GTK settings..."
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface font-name 'Google Sans Flex 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'

# ── what is left to do by hand ──────────────────────────────────────────────
cat <<'EOF'

Done. Still manual:
  - Install the Google Sans Flex font from fonts.google.com
  - Put wallpapers in ~/Pictures/wallpapers/<theme folder> (names in
    ~/.config/niri/scripts/wall-dir.fish), then run wall-thumbs.fish
  - Make sure mako is NOT running (pgrep -x mako): it fights the shell for
    the notification service
  - Log out and back in
EOF
