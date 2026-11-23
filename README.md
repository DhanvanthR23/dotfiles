# dotfiles — wistoria

Minimalist CachyOS rice: **niri** compositor with a hand-written **Quickshell** shell (bar, control center, launcher, lock screen, notifications, OSD, clipboard, theme picker). One color file drives everything.

## Stack

| Component   | Choice                                                                                   |
| ----------- | ---------------------------------------------------------------------------------------- |
| Compositor  | [niri](https://github.com/YaLTeR/niri)                                                   |
| Shell       | [Quickshell](https://quickshell.org) (upstream `quickshell-git`) + `qml-niri`, config in `.config/quickshell` |
| Terminal    | [foot](https://codeberg.org/dnkl/foot)                                                   |
| Wallpaper   | [awww](https://github.com/D-Brox/awww)                                                   |
| Lock / idle | Native Quickshell lock (PAM), idle stages handled by the shell. `hyprlock` is only a fallback |
| Clipboard   | [cliphist](https://github.com/sentriz/cliphist) + wl-clipboard                           |
| GTK / Qt    | adw-gtk3 + libadwaita overrides, [darkly](https://github.com/Bali10050/Darkly) + qt6ct   |
| Shell/prompt| fish + [starship](https://starship.rs) + zoxide                                          |
| File manager| thunar (daemon started with niri), `fd` + fuzzel for fuzzy file search                   |

The shell replaces waybar, mako, swayosd and the session menu. fuzzel is still used by the file search script.

## What the shell does

- **Bar**: floating pills. Launcher, workspaces, clock, CPU/RAM, control pill (Wi-Fi icon inside a battery ring).
- **Clock pill**: hover for a week-strip calendar, weather and media row. Notifications, OSDs and track changes show up as toasts on the pill.
- **Control center**: Wi-Fi, Bluetooth, power profile, night light, updates, keep awake, DND, game mode, tray, volume + per-app mixer, brightness (per-monitor, DDC for externals), notification list.
- **Launcher**: apps plus calculator, usage-ranked, fuzzy matching.
- **Overlays growing out of the pill**: clipboard history, theme + wallpaper picker, session menu.
- **Lock screen**: native Quickshell session lock authenticated through PAM (`.config/quickshell/pam/password.conf`).
- **Idle**: screen off after 5 min, lock after 10 min, lock before sleep. Timeouts live in `config/Settings.qml`.
- **Weather**: Open-Meteo through `curl`, location from `config/Settings.qml`.

## Keybinds (shell related)

| Key                          | Action                         |
| ---------------------------- | ------------------------------ |
| `Mod+D`                      | Launcher                       |
| `Mod+A`                      | Control center                 |
| `Mod+V`                      | Clipboard history              |
| `Mod+Shift+W`                | Theme / wallpaper picker       |
| `Mod+Escape`, `Ctrl+Alt+Del` | Session menu                   |
| `Mod+L`                      | Lock (native)                  |
| `Mod+Shift+L`                | Lock (hyprlock fallback)       |
| `Mod+H`                      | Toggle keep awake              |
| `Mod+Shift+N`                | Clear notifications            |
| `Mod+Shift+U`                | Run system update in a terminal |
| `Mod+Shift+D`                | Fuzzy file search              |
| `Mod+Alt+R`                  | Restart the shell              |

Full IPC target list: `qs ipc show`. Binds live in `.config/niri/config.kdl`.

## Layout

This repo is a single [GNU Stow](https://www.gnu.org/software/stow/) package that mirrors `$HOME`:

```
.config/
├── colors/       # colors.conf = source of truth, themes/ = presets
├── fish/         # shell config
├── fontconfig/   # font rules (Google Sans Flex UI, JetBrainsMono Nerd Font mono)
├── foot/         # terminal
├── fuzzel/       # only used by file-search.sh
├── gtk-3.0/ gtk-4.0/   # GTK theme + generated colors
├── hypr/         # hyprlock (fallback locker); hypridle.conf is unused
├── niri/         # config.kdl + scripts/
├── qt5ct/ qt6ct/ # Qt palettes
├── quickshell/   # the shell (QML), see its README
├── systemd/user/ # doc-sync.service, kdeconnectd.service
├── zathura/
└── starship.toml # generated
.local/share/
├── color-schemes/   # generated Qt color scheme
└── dbus-1/services/ # KDE Connect activation
```

Legacy, kept for reference and no longer used: `.config/waybar/`, `.config/mako/`, `.config/swayosd/`, `.config/waypaper/`, `colors.conf.bak`.

## Deploy

```sh
git clone https://github.com/DhanvanthR23/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is safe to re-run. It installs packages (`paru --needed`), moves conflicting files aside as `*.bak`, stows the repo, makes scripts executable, creates runtime dirs, enables the systemd user units, opens KDE Connect ports if a firewall is active, generates the color files and applies the GTK settings.

Manual steps it cannot do for you:

1. Install the **Google Sans Flex** font (fonts.google.com).
2. Put wallpapers in `~/Pictures/wallpapers/<theme slug>/` (see Theming), then run `set-theme.fish kanagawa`.
3. Make sure no other notification daemon runs (`pgrep -x mako dunst`).
4. Edit the machine-specific values below.
5. Log out and back in.

### Machine-specific values

These are hardcoded for this laptop + monitor and need editing elsewhere:

| What                               | Where                                                  |
| ---------------------------------- | ------------------------------------------------------ |
| Output names, modes, positions     | `.config/niri/config.kdl` (`HDMI-A-1`, `eDP-1`)        |
| Backlight device (`intel_backlight`) | `config.kdl` brightness binds, `services/Brightness.qml` |
| Latitude / longitude (night light + weather) | `.config/quickshell/config/Settings.qml`     |
| Idle timeouts, terminal            | `.config/quickshell/config/Settings.qml`               |

### Dependencies

| Used for                 | Packages                                                              |
| ------------------------ | --------------------------------------------------------------------- |
| Shell                    | `quickshell-git`, `qml-niri`, `ttf-jetbrains-mono-nerd`, Google Sans Flex (manual) |
| System services          | PipeWire + WirePlumber (`wpctl`), NetworkManager, BlueZ, UPower, power-profiles-daemon |
| Brightness               | `brightnessctl`, `ddcutil` (external monitors)                        |
| Night light              | `wlsunset`                                                            |
| Weather                  | `curl`                                                                |
| Clipboard                | `cliphist`, `wl-clipboard`                                            |
| Wallpapers + thumbnails  | `awww`, `imagemagick`, `ripgrep`, `fish`                              |
| File search / manager    | `fd`, `fuzzel`, `thunar`                                              |
| Updates tile             | `pacman-contrib` (`checkupdates`), `paru`                             |
| Network / Bluetooth TUIs | `wlctl`, `bluetui`                                                    |
| Fish config              | `starship`, `zoxide`, `eza`, `bat`, `fzf`, `trash-cli`, `fastfetch`, `neovim` |
| Doc sync + phone         | `inotify-tools`, `rsync`, `kdeconnect`, `sshfs`                       |
| Theming                  | `stow`, `qt6ct`, `qt5ct`, `darkly`, `adw-gtk-theme`                   |
| Fallback lock            | `hyprlock`                                                            |

## Theming

`.config/colors/colors.conf` (`COLOR_*=hex`) is the single source of truth. Available presets in `.config/colors/themes/`: catppuccin-mocha, dracula, everforest, gruvbox-dark, kanagawa, nord, one-dark, rose-pine, rose-pine-moon, tokyo-night.

Switch from the shell picker (`Mod+Shift+W`) or a terminal:

```sh
~/.config/niri/scripts/set-theme.fish <slug> [wallpaper | --keep]
```

This copies `themes/<slug>.conf` over `colors.conf`, runs `generate-colors.sh` (niri, foot, fuzzel, zathura, hyprlock, GTK3/4, Qt, starship), picks a random wallpaper from `~/Pictures/wallpapers/<slug>/`, and tells the running shell to recolor via `qs ipc call theme reload`.

The wallpaper folder name equals the theme slug, except `rose-pine-moon`, which uses `rose-pine`.

`colors.conf` itself is gitignored, so theme switches don't dirty `git status`. `install.sh` seeds it from `themes/kanagawa.conf` on a fresh clone.

Generated files (`colors.css`, `colors.kdl`, `colors-*.ini`, `starship.toml`, ...) are gitignored. The `Rosé Pine` names inside the generated Qt and GTK files are cosmetic, they carry whichever theme is active.

## Scripts

All in `.config/niri/scripts/`.

In use: `set-theme.fish`, `wall-list.fish`, `wall-thumbs.fish`, `wall-dir.fish`, `generate-colors.sh`, `lock.sh` (hyprlock fallback), `file-search.sh`, `sync-documents.sh` (run by `doc-sync.service`). Anything the shell calls by path must stay in this folder.

Left over from the waybar/mako era and not referenced anymore: `awww-restore.sh`, `battery-cycle.fish`, `bluetooth.sh`, `check-updates.sh`, `notif-menu.sh`, `quickshell-launcher.fish`, `run-updates.sh`, `session.sh`, `toggle-idle.fish`, `volume-up.sh`.

## systemd user units

`install.sh` enables every unit in `.config/systemd/user/`: `doc-sync.service` (mirrors `~/Documents` to `/mnt/storage/Documents`) and `kdeconnectd.service`. It also masks the GNOME tracker services to save RAM and IO.

## Runtime state

The shell keeps state outside the repo, still under its old project name:

- `~/.local/state/qs-test/`: current theme, wallpaper, launcher history
- `~/.cache/qs-test/`: wallpaper thumbnails, update-count cache

Renaming these means editing the paths in `set-theme.fish`, `wall-thumbs.fish`, `wall-list.fish`, `update-count.sh`, `Themes.qml`, `Lock.qml` and the wallpaper line in `config.kdl`.

## Notes

- Restart the shell with `Mod+Alt+R` if it crashes. It runs with `QT_QUICK_BACKEND=software` (set in niri's `environment` block) to keep idle memory around 90 MB.
- Don't run mako or dunst alongside the shell: only one process can own the notification service.
- The native lock needs the PAM file at `~/.config/quickshell/pam/password.conf`, which stow provides.
