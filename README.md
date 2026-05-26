# dotfiles — requiem
Tokyo Night Storm rice on EndeavourOS + Niri

## stack
- compositor: niri
- bar: waybar
- launcher: fuzzel
- notifications: mako
- terminal: foot
- wallpaper: swww + waypaper
- lock: hyprlock + hypridle
- gtk: tokyonight-gtk-theme
- qt: darkly + qt6ct
- prompt: starship
- clipboard: cliphist

## deploy
paru -S waybar mako fuzzel foot cliphist wl-clipboard \
  hyprlock hypridle swww waypaper \
  tokyonight-gtk-theme-git darkly qt6ct qt5ct \
  ttf-jetbrains-mono-nerd starship pacman-contrib \
  libnotify playerctl xdg-desktop-portal-gtk

stow . --target=$HOME
