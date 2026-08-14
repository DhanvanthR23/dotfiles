# dotfiles — wistoria

> Minimalist CachyOS rice with niri + waybar

## Stack

| Component        | Choice                                                              |
| ---------------- | ------------------------------------------------------------------- |
| Compositor       | [niri](https://github.com/niri-wm/niri)                            |
| Bar              | [waybar](https://github.com/Alexays/Waybar)                         |
| Launcher         | [fuzzel](https://codeberg.org/dnkl/fuzzel)                          |
| Notifications    | [mako](https://github.com/emersion/mako)                            |
| Terminal         | [foot](https://codeberg.org/dnkl/foot)                              |
| Wallpaper        | [swww](https://github.com/LGFae/swww) + [waypaper](https://github.com/anufrievroman/waypaper) |
| Lock screen      | [hyprlock](https://github.com/hyprwm/hyprlock) + [hypridle](https://github.com/hyprwm/hypridle) |
| GTK theme        | [tokyonight-gtk-theme](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme) |
| Qt theme         | [darkly](https://github.com/Bali10050/Darkly) + [qt6ct](https://github.com/trialuser02/qt6ct) |
| Prompt           | [starship](https://github.com/starship/starship)                    |
| Clipboard        | [cliphist](https://github.com/sentriz/cliphist) + [wl-clipboard](https://github.com/bugaevc/wl-clipboard) |

## Deploy

```sh
# install the helper script
./install.sh
```

The script will:
1. Install all required packages via `paru`
2. Back up existing configs in `~/.config`
3. Stow dotfiles into `$HOME`
4. Fix script permissions and apply the GTK theme

### Manual steps

- Install **Google Sans Flex** manually from [fonts.google.com](https://fonts.google.com)
- Log out and back in for all changes to take effect

## Structure

```
.config/
├── colors/          # source of truth for the color scheme (colors.conf)
├── fish/            # shell config, aliases, functions
├── foot/            # terminal theme
├── fontconfig/      # font fallback rules
├── fuzzel/          # launcher theme
├── gtk-3.0/         # GTK3 theme + colors
├── gtk-4.0/         # GTK4 theme + colors
├── hypr/            # hyprlock + hypridle
├── mako/            # notification daemon
├── niri/            # compositor config + scripts
├── qt5ct/           # Qt5 palette
├── qt6ct/           # Qt6 palette
├── starship.toml    # prompt
├── templates/       # shell templates
├── waybar/          # status bar
├── waypaper/        # wallpaper picker
└── zathura/         # PDF viewer theme
```

`.config/colors/colors.conf` is the single source of truth. Run
`.config/niri/scripts/generate-colors.sh` after editing it to propagate the
scheme to niri, waybar, mako, foot, fuzzel, hyprlock, GTK3/4, Qt, and
zathura.
