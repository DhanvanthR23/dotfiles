#!/usr/bin/env bash
# install.sh — deploy these dotfiles on a fresh CachyOS/Arch box (niri + Quickshell)
# Safe to re-run: packages use --needed, stow is restowed, conflicts are moved aside.
set -euo pipefail

cd "$(dirname "$0")"
warn() { printf '  !! %s\n' "$*" >&2; }

# ── packages ────────────────────────────────────────────────────────────────
# Core: the script aborts if any of these fail.
CORE=(
  # compositor + shell runtime
  niri foot awww
  cliphist wl-clipboard libnotify playerctl curl
  brightnessctl ddcutil wlsunset
  pacman-contrib imagemagick ripgrep fd fuzzel thunar
  # system services the shell talks to
  pipewire wireplumber networkmanager bluez bluez-utils upower power-profiles-daemon
  # theming
  stow qt6ct qt5ct darkly adw-gtk-theme gtk-engine-murrine
  xdg-desktop-portal-gtk polkit-gnome
  ttf-jetbrains-mono-nerd
  # fish config assumes these (zoxide/starship init, eza/bat/trash aliases, fcd)
  fish starship zoxide eza bat fzf trash-cli fastfetch
  # doc-sync.service + KDE Connect
  kdeconnect inotify-tools rsync
)

# AUR / less common names: tried one by one, a failure only warns.
# Verify these names on your system (paru -Ss <name>) before relying on them.
OPTIONAL=(
  quickshell-git # upstream Quickshell the shell runs on
  qml-niri       # Niri QML module (import Niri)
  wlctl          # Wi-Fi TUI opened by right-click on the Wi-Fi tile
  bluetui        # Bluetooth TUI opened by right-click on the Bluetooth tile
  hyprlock       # fallback locker, bound to Mod+Shift+L (Mod+L is the native lock)
  sshfs          # KDE Connect "browse phone filesystem"
  neovim         # $EDITOR in config.fish
  bibata-cursor-theme # cursor set in niri + GTK settings
  hyprpicker btop localsend scrcpy android-tools # apps bound in config.kdl / fish `scr`
)

echo "==> Installing core packages..."
paru -S --needed "${CORE[@]}"

echo "==> Installing optional packages..."
for pkg in "${OPTIONAL[@]}"; do
  paru -S --needed "$pkg" || warn "could not install $pkg, install it manually"
done

# ── system services ─────────────────────────────────────────────────────────
# The control center needs BlueZ, UPower and power-profiles-daemon running.
echo "==> Enabling system services..."
for svc in bluetooth upower power-profiles-daemon NetworkManager; do
  sudo systemctl enable --now "$svc" || warn "could not enable $svc"
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

# colors.conf is gitignored (it changes on every theme switch), so a fresh clone
# has none and generate-colors.sh would abort. Seed it from the default theme.
if [ ! -f ~/.config/colors/colors.conf ]; then
  echo "==> Seeding colors.conf from the kanagawa theme..."
  cp ~/.config/colors/themes/kanagawa.conf ~/.config/colors/colors.conf
fi

echo "==> Fixing script permissions..."
chmod +x ~/.config/niri/scripts/*.sh ~/.config/niri/scripts/*.fish

# ── runtime dirs + initial state the shell expects ──────────────────────────
echo "==> Creating runtime directories..."
mkdir -p ~/Pictures/wallpapers ~/Pictures/Screenshots ~/.local/state/qs-test ~/.cache/qs-test
# The picker shows "Apply a theme first" until this file exists. Matches the
# committed colors.conf (Kanagawa).
[ -f ~/.local/state/qs-test/theme ] || echo kanagawa >~/.local/state/qs-test/theme

# ── systemd user units ──────────────────────────────────────────────────────
# Every unit shipped in .config/systemd/user/ gets enabled (templates skipped).
# Drop a new .service/.timer/.path there, re-run this script, done.
echo "==> Enabling systemd user units..."
if systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user daemon-reload

  # Masked on purpose (file indexers eat RAM/IO). Mask = symlink to /dev/null,
  # so these are created here, not shipped in the repo.
  for t in extract miner-fs miner-rss writeback xdg-portal; do
    systemctl --user mask "tracker-$t-3.service" || warn "could not mask tracker-$t-3.service"
  done

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
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'

# ── what is left to do by hand ──────────────────────────────────────────────
cat <<'EOF'

Done. Still manual:
  - Install the Google Sans Flex font from fonts.google.com
  - Edit the machine-specific values (see "Machine-specific values" in the README):
      niri config.kdl outputs + intel_backlight, quickshell config/Settings.qml
      latitude/longitude
  - Put wallpapers in ~/Pictures/wallpapers/<theme slug>/ (rose-pine-moon uses
    rose-pine/), then run:  ~/.config/niri/scripts/set-theme.fish kanagawa
  - Make sure no other notification daemon runs (pgrep -x mako; pgrep -x dunst):
    it fights the shell for the notification service
  - Optional: chsh -s "$(command -v fish)"
  - Log out and back in
EOF
