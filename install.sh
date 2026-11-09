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
  kdeconnect
)

# AUR / less common names: tried one by one, a failure only warns.
# Verify these names on your system (paru -Ss <name>) before relying on them.
OPTIONAL=(
  noctalia-qs # Quickshell fork the shell runs on (or plain `quickshell`)
  wlctl       # Wi-Fi TUI opened by right-click on the Wi-Fi tile
  bluetui     # Bluetooth TUI opened by right-click on the Bluetooth tile
  sshfs       # KDE Connect "browse phone filesystem"
)

echo "==> Installing core packages..."
paru -S --needed "${CORE[@]}"

echo "==> Installing optional packages..."
for pkg in "${OPTIONAL[@]}"; do
  paru -S --needed "$pkg" || warn "could not install $pkg, install it manually"
done

# ── stow ────────────────────────────────────────────────────────────────────
# Real dirs must exist first, else stow folds them into one symlink to the repo
# and `systemctl --user enable` then writes *.wants/ symlinks inside the repo.
mkdir -p ~/.config/systemd/user ~/.local/share/dbus-1/services

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

# ── systemd user units ──────────────────────────────────────────────────────
# Every unit shipped in .config/systemd/user/ gets enabled (templates skipped).
# Drop a new .service/.timer/.path there, re-run this script, done.
echo "==> Enabling systemd user units..."
if systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user daemon-reload
  shopt -s nullglob
  for f in .config/systemd/user/*.service .config/systemd/user/*.timer .config/systemd/user/*.path; do
    unit=$(basename "$f")
    [[ $unit == *@* ]] && continue
    systemctl --user enable "$unit" || warn "could not enable $unit"
    # Only start now if a graphical session is already up, else it starts at login.
    if systemctl --user is-active --quiet graphical-session.target; then
      systemctl --user restart "$unit" || warn "could not start $unit"
    fi
  done
  shopt -u nullglob
else
  warn "no systemd user bus (ssh/chroot?), units not enabled. Re-run from a login session."
fi

# ── KDE Connect firewall ────────────────────────────────────────────────────
# Phone never finds the PC if 1714-1764 tcp+udp is blocked.
echo "==> Opening KDE Connect ports (if a firewall is active)..."
if command -v ufw >/dev/null && [[ $(sudo ufw status) == *"Status: active"* ]]; then
  sudo ufw allow 1714:1764/tcp
  sudo ufw allow 1714:1764/udp
elif command -v firewall-cmd >/dev/null && sudo firewall-cmd --state >/dev/null 2>&1; then
  sudo firewall-cmd --permanent --add-service=kdeconnect
  sudo firewall-cmd --reload
else
  echo "  no active ufw/firewalld, skipping"
fi

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
