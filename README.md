# dotfiles — wistoria

Minimalist CachyOS rice: **niri** compositor with a hand-written **Quickshell** shell (bar, control center, launcher, notifications, OSD, theme picker). One color file drives everything.

## Stack

| Component     | Choice                                                                                          |
| ------------- | ----------------------------------------------------------------------------------------------- |
| Compositor    | [niri](https://github.com/YaLTeR/niri)                                                          |
| Shell         | [Quickshell](https://quickshell.org) (noctalia-qs fork), config in `.config/quickshell`         |
| Terminal      | [foot](https://codeberg.org/dnkl/foot)                                                          |
| Wallpaper     | [awww](https://github.com/D-Brox/awww)                                                          |
| Lock / idle   | [hyprlock](https://github.com/hyprwm/hyprlock), idle stages handled by the shell                |
| Clipboard     | [cliphist](https://github.com/sentriz/cliphist) + wl-clipboard                                  |
| GTK / Qt      | adw-gtk3 + libadwaita overrides, [darkly](https://github.com/Bali10050/Darkly) + qt6ct          |
| Prompt        | [starship](https://starship.rs)                                                                 |

The shell replaces waybar, mako, swayosd, fuzzel and the session menu. Its own README (`.config/quickshell/README.md`) has the full IPC target and keybind tables.

## Layout

This repo is a single [GNU Stow](https://www.gnu.org/software/stow/) package that mirrors `$HOME`:

```
.config/
├── colors/       # colors.conf = source of truth, themes/ = presets
├── fish/         # shell config
├── fontconfig/   # font fallback rules
├── foot/         # terminal
├── gtk-3.0/      # GTK3 theme + colors
├── gtk-4.0/      # GTK4 theme + colors
├── hypr/         # hyprlock config
├── niri/         # config.kdl + scripts/
├── qt5ct/ qt6ct/ # Qt palettes
├── quickshell/   # the shell (QML), see its README
├── starship.toml
└── zathura/
.local/share/color-schemes/   # generated Qt color scheme
```

## Deploy

```sh
git clone https://github.com/DhanvanthR23/dotfiles ~/dotfiles
cd ~/dotfiles
stow . --target="$HOME"        # existing real files in the way = conflict, move them first
chmod +x ~/.config/niri/scripts/*.sh ~/.config/niri/scripts/*.fish
~/.config/niri/scripts/generate-colors.sh
```

`install.sh` automates this, but it still targets the old waybar/mako stack. Check it before trusting it on a fresh machine.

### Dependencies

| Used for                 | Packages                                        |
| ------------------------ | ----------------------------------------------- |
| Shell                    | `quickshell` (noctalia-qs), `ttf-jetbrains-mono-nerd`, Google Sans Flex (manual) |
| Brightness               | `brightnessctl`, `ddcutil` (external monitors)  |
| Night light              | `wlsunset`                                      |
| Clipboard                | `cliphist`, `wl-clipboard`                      |
| Wallpapers + thumbnails  | `awww`, `imagemagick`, `ripgrep`, `fish`        |
| Updates tile             | `pacman-contrib` (`checkupdates`), `paru`       |
| Network / Bluetooth TUIs | `wlctl`, `bluetui`                              |
| Lock                     | `hyprlock`                                      |
| Theming                  | `stow`, `qt6ct`, `qt5ct`, `darkly`, `adw-gtk3` |

## Theming

`.config/colors/colors.conf` (`COLOR_*=hex`) is the single source of truth. Switch themes from the shell picker, or from a terminal:

```sh
~/.config/niri/scripts/set-theme.fish <slug> [wallpaper | --keep]
```

This copies `themes/<slug>.conf` over `colors.conf`, runs `generate-colors.sh` (niri, foot, hyprlock, GTK3/4, Qt, zathura), picks a wallpaper from the matching folder in `~/Pictures/wallpapers`, and tells the running shell to recolor via `qs ipc call theme reload`.

Generated files (`colors.css`, `colors.kdl`, `colors-*.ini`, ...) are gitignored.

## Scripts

Everything lives in `.config/niri/scripts/`. Anything the shell calls by path (`set-theme.fish`, `wall-list.fish`, `wall-thumbs.fish`, `wall-dir.fish`, `lock.sh`, `generate-colors.sh`) must stay there.

## Runtime state

The shell keeps state outside the repo, still under its old project name:

- `~/.local/state/qs-test/`: current theme, wallpaper, launcher history
- `~/.cache/qs-test/`: wallpaper thumbnails, update-count cache

Renaming these means editing the paths in `set-theme.fish`, `wall-thumbs.fish`, `update-count.sh`, `Themes.qml` and the wallpaper line in `config.kdl`.

## Notes

- Restart the shell with `Mod+Shift+W` if it crashes. It must run with `QT_QUICK_BACKEND=software` to keep idle memory around 90 MB.
- Don't run mako alongside the shell: only one process can own the notification service.
