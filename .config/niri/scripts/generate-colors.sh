#!/usr/bin/env bash
# generate-colors.sh — propagate colors.conf to all tool configs
set -euo pipefail

COLORS="${XDG_CONFIG_HOME:-$HOME/.config}/colors/colors.conf"
if [[ ! -f "$COLORS" ]]; then
  echo "ERROR: $COLORS not found" >&2
  exit 1
fi
source "$COLORS"

OUT="${XDG_CONFIG_HOME:-$HOME/.config}/colors"
mkdir -p "$OUT"

# ── Niri (KDL) ───────────────────────────────────────────────────────────────
cat >"$OUT/colors.kdl" <<EOF
layout {
    focus-ring {
        active-color   "#${COLOR_BORDER}"
        inactive-color "#${COLOR_FG_MUTED}"
        urgent-color   "#${COLOR_RED}"
    }
    border {
        on
        active-color   "#${COLOR_BORDER}"
        inactive-color "#${COLOR_FG_MUTED}"
        urgent-color   "#${COLOR_RED}"
    }
    shadow {
        color "#${COLOR_BG}88"
    }
    tab-indicator {
        active-color   "#${COLOR_BORDER}"
        inactive-color "#${COLOR_FG_MUTED}"
        urgent-color   "#${COLOR_RED}"
    }
    insert-hint {
        color "#${COLOR_PINE}80"
    }
}
recent-windows {
    highlight {
        active-color "#${COLOR_BORDER}"
        urgent-color "#${COLOR_RED}"
    }
}
EOF

# ── Foot ─────────────────────────────────────────────────────────────────────
cat >"$OUT/colors-foot.ini" <<EOF
[colors-dark]
background=${COLOR_BG}
foreground=${COLOR_FG}
cursor=${COLOR_BG} ${COLOR_PINE}
selection-foreground=${COLOR_FG}
selection-background=${COLOR_SELECTION}

regular0=${COLOR_BLACK}
regular1=${COLOR_RED_N}
regular2=${COLOR_GREEN_N}
regular3=${COLOR_YELLOW_N}
regular4=${COLOR_BLUE_N}
regular5=${COLOR_MAGENTA_N}
regular6=${COLOR_CYAN_N}
regular7=${COLOR_FG_SUBTLE}

bright0=${COLOR_BRIGHT_BLACK}
bright1=${COLOR_BRIGHT_RED}
bright2=${COLOR_BRIGHT_GREEN}
bright3=${COLOR_BRIGHT_YELLOW}
bright4=${COLOR_BRIGHT_BLUE}
bright5=${COLOR_BRIGHT_MAGENTA}
bright6=${COLOR_BRIGHT_CYAN}
bright7=${COLOR_BRIGHT_WHITE}

dim0=${COLOR_DIM_BLACK}
dim1=${COLOR_DIM_RED}
dim2=${COLOR_DIM_GREEN}
dim3=${COLOR_DIM_YELLOW}
dim4=${COLOR_DIM_BLUE}
dim5=${COLOR_DIM_MAGENTA}
dim6=${COLOR_DIM_CYAN}
dim7=${COLOR_DIM_WHITE}
EOF

# ── Fuzzel ───────────────────────────────────────────────────────────────────
cat >"$OUT/colors-fuzzel.ini" <<EOF
[colors]
background=${COLOR_BG}ff
text=${COLOR_FG}ff
match=${COLOR_PINE}ff
selection=${COLOR_OVERLAY}ff
selection-text=${COLOR_FG}ff
selection-match=${COLOR_FOAM}ff
border=${COLOR_FG_MUTED}ff
prompt=${COLOR_IRIS}ff
placeholder=${COLOR_FG_MUTED}88
input=${COLOR_FG}ff
EOF

# ── Zathura ───────────────────────────────────────────────────────────────────
cat >"$OUT/colors-zathura" <<EOF
set default-bg "#${COLOR_BG}"
set default-fg "#${COLOR_FG}"
set recolor-darkcolor "#${COLOR_FG}"
set recolor-lightcolor "#${COLOR_BG}"
set statusbar-bg "#${COLOR_BG}"
set statusbar-fg "#${COLOR_FG}"
set inputbar-bg "#${COLOR_SURFACE}"
set inputbar-fg "#${COLOR_FG}"
set notification-error-bg "#${COLOR_RED}"
set notification-error-fg "#${COLOR_BG}"
set notification-warning-bg "#${COLOR_GOLD}"
set notification-warning-fg "#${COLOR_BG}"
set notification-bg "#${COLOR_SURFACE}"
set notification-fg "#${COLOR_FG}"
set index-bg "#${COLOR_BG}"
set index-fg "#${COLOR_FG}"
set index-active-bg "#${COLOR_IRIS}"
set index-active-fg "#${COLOR_BG}"
set completion-bg "#${COLOR_BG}"
set completion-fg "#${COLOR_FG}"
set completion-group-bg "#${COLOR_SURFACE}"
set completion-group-fg "#${COLOR_FG_SUBTLE}"
set completion-highlight-bg "#${COLOR_SELECTION}"
set completion-highlight-fg "#${COLOR_FG}"
set highlight-color "#${COLOR_SELECTION}"
set highlight-active-color "#${COLOR_PINE}"
set recolor true
EOF

# ── Hyprlock (hyprlang vars) ─────────────────────────────────────────────────
cat >"$OUT/colors-hypr.conf" <<EOF
\$border_color=rgb(${COLOR_BORDER})
\$bg_color=rgb(${COLOR_BG})
\$text_color=rgb(${COLOR_FG})
\$accent_color=rgb(${COLOR_PINE})
\$fail_color=rgb(${COLOR_RED})
\$warning_color=rgb(${COLOR_GOLD})
\$shadow_color=rgba(${COLOR_BG}88)
\$dim_color=rgb(${COLOR_FG_MUTED})
EOF

# ── Qt colorscheme ───────────────────────────────────────────────────────────
QT_DIR="${HOME}/.local/share/color-schemes"
mkdir -p "$QT_DIR"

# Convert hex to R,G,B decimal
hex_to_rgb() {
  local hex="$1"
  printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

BG_RGB=$(hex_to_rgb "$COLOR_BG")
SURFACE_RGB=$(hex_to_rgb "$COLOR_SURFACE")
FG_RGB=$(hex_to_rgb "$COLOR_FG")
FG_MUTED_RGB=$(hex_to_rgb "$COLOR_FG_MUTED")
PINE_RGB=$(hex_to_rgb "$COLOR_PINE")
FOAM_RGB=$(hex_to_rgb "$COLOR_FOAM")
RED_RGB=$(hex_to_rgb "$COLOR_RED")
GOLD_RGB=$(hex_to_rgb "$COLOR_GOLD")
IRIS_RGB=$(hex_to_rgb "$COLOR_IRIS")
DIM_BLACK_RGB=$(hex_to_rgb "$COLOR_DIM_BLACK")

cat >"$QT_DIR/RosePine.colors" <<EOF
[ColorEffects:Disabled]
Color=${FG_MUTED_RGB}
ColorAmount=0.55
ColorEffect=3
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=${FG_MUTED_RGB}
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=${SURFACE_RGB}
BackgroundNormal=${SURFACE_RGB}
DecorationFocus=${PINE_RGB}
DecorationHover=${FOAM_RGB}
ForegroundActive=${PINE_RGB}
ForegroundInactive=${FG_MUTED_RGB}
ForegroundLink=${FOAM_RGB}
ForegroundNegative=${RED_RGB}
ForegroundNeutral=${GOLD_RGB}
ForegroundNormal=${FG_RGB}
ForegroundPositive=${FOAM_RGB}
ForegroundVisited=${IRIS_RGB}

[Colors:Complementary]
BackgroundAlternate=${DIM_BLACK_RGB}
BackgroundNormal=${SURFACE_RGB}
DecorationFocus=${PINE_RGB}
DecorationHover=${FOAM_RGB}
ForegroundActive=${PINE_RGB}
ForegroundInactive=${FG_MUTED_RGB}
ForegroundLink=${FOAM_RGB}
ForegroundNegative=${RED_RGB}
ForegroundNeutral=${GOLD_RGB}
ForegroundNormal=${FG_RGB}
ForegroundPositive=${FOAM_RGB}
ForegroundVisited=${IRIS_RGB}

[Colors:Header]
BackgroundAlternate=${SURFACE_RGB}
BackgroundNormal=${SURFACE_RGB}
DecorationFocus=${PINE_RGB}
DecorationHover=${FOAM_RGB}
ForegroundActive=${FG_RGB}
ForegroundInactive=${FG_MUTED_RGB}
ForegroundLink=${FOAM_RGB}
ForegroundNegative=${RED_RGB}
ForegroundNeutral=${GOLD_RGB}
ForegroundNormal=${FG_RGB}
ForegroundPositive=${FOAM_RGB}
ForegroundVisited=${IRIS_RGB}

[Colors:Selection]
BackgroundAlternate=${PINE_RGB}
BackgroundNormal=${PINE_RGB}
DecorationFocus=${PINE_RGB}
DecorationHover=${FOAM_RGB}
ForegroundActive=${BG_RGB}
ForegroundInactive=${BG_RGB}
ForegroundLink=${BG_RGB}
ForegroundNegative=${RED_RGB}
ForegroundNeutral=${GOLD_RGB}
ForegroundNormal=${BG_RGB}
ForegroundPositive=${FOAM_RGB}
ForegroundVisited=${BG_RGB}

[Colors:Tooltip]
BackgroundAlternate=${SURFACE_RGB}
BackgroundNormal=${SURFACE_RGB}
DecorationFocus=${PINE_RGB}
DecorationHover=${FOAM_RGB}
ForegroundActive=${PINE_RGB}
ForegroundInactive=${FG_MUTED_RGB}
ForegroundLink=${FOAM_RGB}
ForegroundNegative=${RED_RGB}
ForegroundNeutral=${GOLD_RGB}
ForegroundNormal=${FG_RGB}
ForegroundPositive=${FOAM_RGB}
ForegroundVisited=${IRIS_RGB}

[Colors:View]
BackgroundAlternate=${SURFACE_RGB}
BackgroundNormal=${BG_RGB}
DecorationFocus=${PINE_RGB}
DecorationHover=${FOAM_RGB}
ForegroundActive=${PINE_RGB}
ForegroundInactive=${FG_MUTED_RGB}
ForegroundLink=${FOAM_RGB}
ForegroundNegative=${RED_RGB}
ForegroundNeutral=${GOLD_RGB}
ForegroundNormal=${FG_RGB}
ForegroundPositive=${FOAM_RGB}
ForegroundVisited=${IRIS_RGB}

[Colors:Window]
BackgroundAlternate=${SURFACE_RGB}
BackgroundNormal=${SURFACE_RGB}
DecorationFocus=${PINE_RGB}
DecorationHover=${FOAM_RGB}
ForegroundActive=${PINE_RGB}
ForegroundInactive=${FG_MUTED_RGB}
ForegroundLink=${FOAM_RGB}
ForegroundNegative=${RED_RGB}
ForegroundNeutral=${GOLD_RGB}
ForegroundNormal=${FG_RGB}
ForegroundPositive=${FOAM_RGB}
ForegroundVisited=${IRIS_RGB}

[General]
ColorScheme=RosePine
Name=Rosé Pine
shadeSortColumn=true

[KDE]
contrast=4
EOF

# ── GTK colors ──────────────────────────────────────────────────────────────
# GTK3: legacy theme_* variables
GTK3_COLORS_CONTENT="@define-color theme_bg_color #${COLOR_BG};
@define-color theme_fg_color #${COLOR_FG};
@define-color theme_base_color #${COLOR_DIM_BLACK};
@define-color theme_text_color #${COLOR_FG};
@define-color theme_selected_bg_color #${COLOR_PINE};
@define-color theme_selected_fg_color #${COLOR_BG};
@define-color theme_tooltip_bg_color #${COLOR_SURFACE};
@define-color theme_tooltip_fg_color #${COLOR_FG};
@define-color theme_link_color #${COLOR_FOAM};
@define-color theme_link_visited_color #${COLOR_IRIS};

@define-color wm_title #${COLOR_FG};
@define-color wm_title_background #${COLOR_SURFACE};
@define-color wm_title_foreground #${COLOR_FG};
@define-color wm_highlight #${COLOR_PINE};
@define-color wm_highlight_foreground #${COLOR_BG};
@define-color wm_borders #${COLOR_BORDER};
@define-color wm_button_close_color #${COLOR_RED};
@define-color wm_button_maximize_color #${COLOR_FOAM};
@define-color wm_button_minimize_color #${COLOR_GOLD};
"

# GTK4: libadwaita color variables
GTK4_COLORS_CONTENT="/* Rosé Pine — libadwaita color overrides */
@define-color accent_bg_color #${COLOR_IRIS};
@define-color accent_fg_color #${COLOR_BG};
@define-color accent_color #${COLOR_IRIS};

@define-color destructive_bg_color #${COLOR_RED};
@define-color destructive_fg_color #${COLOR_BG};
@define-color destructive_color #${COLOR_RED};

@define-color success_bg_color #${COLOR_FOAM};
@define-color success_fg_color #${COLOR_FG};
@define-color success_color #${COLOR_FOAM};

@define-color warning_bg_color #${COLOR_GOLD};
@define-color warning_fg_color #${COLOR_FG};
@define-color warning_color #${COLOR_GOLD};

@define-color error_bg_color #${COLOR_RED};
@define-color error_fg_color #${COLOR_FG};
@define-color error_color #${COLOR_RED};

@define-color window_bg_color #${COLOR_BG};
@define-color window_fg_color #${COLOR_FG};

@define-color view_bg_color #${COLOR_BG};
@define-color view_fg_color #${COLOR_FG};

@define-color headerbar_bg_color #${COLOR_SURFACE};
@define-color headerbar_fg_color #${COLOR_FG};
@define-color headerbar_backdrop_color #${COLOR_BG};
@define-color headerbar_shade_color #${COLOR_BG};

@define-color card_bg_color #${COLOR_SURFACE};
@define-color card_fg_color #${COLOR_FG};
@define-color card_shade_color #${COLOR_BG};

@define-color popover_bg_color #${COLOR_SURFACE};
@define-color popover_fg_color #${COLOR_FG};

@define-color sidebar_bg_color #${COLOR_BG};
@define-color sidebar_fg_color #${COLOR_FG};

/* Legacy GTK3 vars for compatibility */
@define-color theme_bg_color #${COLOR_BG};
@define-color theme_fg_color #${COLOR_FG};
@define-color theme_base_color #${COLOR_DIM_BLACK};
@define-color theme_selected_bg_color #${COLOR_PINE};
@define-color theme_selected_fg_color #${COLOR_BG};
"

echo "$GTK4_COLORS_CONTENT" >"${HOME}/.config/gtk-3.0/colors.css"
echo "$GTK4_COLORS_CONTENT" >"${HOME}/.config/gtk-4.0/colors.css"

# ── Starship ─────────────────────────────────────────────────────────────────
cat >"${HOME}/.config/starship.toml" <<EOF
# Auto-generated by generate-colors.sh — do not edit manually
"\$schema" = 'https://starship.rs/config-schema.json'

format = """\\
[](fg:#${COLOR_BG})\\
\$os\\
[](bg:#${COLOR_SURFACE} fg:#${COLOR_BG})\\
\$directory\\
\$git_branch\\
\$git_status\\
[](fg:#${COLOR_SURFACE})\\
 \\
\$nodejs\$python\$rust\$golang\$java\\
\$fill\\
\$cmd_duration\\
\$status\\
\$line_break\\
\$character"""

[os]
format = "[ \$symbol ](bg:#${COLOR_BG} fg:#${COLOR_PINE})"
disabled = false

[os.symbols]
Linux = ""
Arch = "󰣇"
EndeavourOS = ""

[directory]
format = "[ 󰉋 \$path ](\$style)"
style = "bg:#${COLOR_SURFACE} fg:#${COLOR_FG}"
truncation_length = 3
truncate_to_repo = true
truncation_symbol = "…/"
read_only = " 󰌾"
read_only_style = "bg:#${COLOR_SURFACE} fg:#${COLOR_RED}"

[git_branch]
format = "[ \$symbol\$branch ](\$style)"
symbol = " "
style = "bg:#${COLOR_SURFACE} fg:#${COLOR_PINE}"
truncation_length = 20
truncation_symbol = "…"

[git_status]
format = "[\$all_status\$ahead_behind](\$style)"
style = "bg:#${COLOR_SURFACE} fg:#${COLOR_IRIS}"
conflicted = " "
ahead = "⇡\${count} "
behind = "⇣\${count} "
diverged = "⇕⇡\${ahead_count}⇣\${behind_count} "
untracked = "󰛄 \${count} "
stashed = " "
modified = "󰏫 \${count} "
staged = "󰐗 \${count} "
renamed = "󰁔 \${count} "
deleted = "󰍶 \${count} "

[nodejs]
format = "[ 󰎙 \$version ](fg:#${COLOR_GREEN_N})"
symbol = "󰎙 "

[python]
format = "[  \$version ](fg:#${COLOR_GOLD})"
symbol = " "

[rust]
format = "[ 󱘗 \$version ](fg:#${COLOR_RED})"
symbol = "󱘗 "

[golang]
format = "[  \$version ](fg:#${COLOR_FOAM})"
symbol = " "

[java]
format = "[  \$version ](fg:#${COLOR_RED})"
symbol = " "

[fill]
symbol = " "

[cmd_duration]
format = "[ 󱎫 \$duration ](fg:#${COLOR_GOLD})"
min_time = 2_000
show_milliseconds = false

[status]
format = "[ \$symbol\$status ](fg:#${COLOR_RED})"
symbol = "󰅚 "
success_symbol = ""
not_executable_symbol = "󰉖 "
not_found_symbol = "󰍉 "
sigint_symbol = "󰂭 "
signal_symbol = "󱐋 "
disabled = false

[character]
success_symbol = "[▸](fg:#${COLOR_GREEN_N})"
error_symbol = "[▸](fg:#${COLOR_RED})"
vimcmd_symbol = "[◂](fg:#${COLOR_IRIS})"

[line_break]
disabled = false

[package]
disabled = true

[docker_context]
disabled = true

[terraform]
disabled = true

[kubernetes]
disabled = true
EOF

# ── Zed ──────────────────────────────────────────────────────────────────────
ZED_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zed/themes"
mkdir -p "$ZED_DIR"
cat >"$ZED_DIR/colors.json" <<EOF
{
  "\$schema": "https://zed.dev/schema/themes/v0.2.0.json",
  "name": "Colors",
  "author": "generated",
  "themes": [{
    "name": "Colors",
    "appearance": "dark",
    "style": {
      "background": "#${COLOR_BG}",
      "surface.background": "#${COLOR_SURFACE}",
      "elevated_surface.background": "#${COLOR_SURFACE}",
      "title_bar.background": "#${COLOR_BG}",
      "status_bar.background": "#${COLOR_BG}",
      "toolbar.background": "#${COLOR_BG}",
      "tab_bar.background": "#${COLOR_SURFACE}",
      "tab.active_background": "#${COLOR_BG}",
      "tab.inactive_background": "#${COLOR_SURFACE}",
      "panel.background": "#${COLOR_BG}",
      "border": "#${COLOR_BORDER}",
      "border.variant": "#${COLOR_OVERLAY}",
      "border.focused": "#${COLOR_IRIS}",
      "border.selected": "#${COLOR_IRIS}",
      "element.background": "#${COLOR_SURFACE}",
      "element.hover": "#${COLOR_OVERLAY}",
      "element.active": "#${COLOR_SELECTION}",
      "element.selected": "#${COLOR_SELECTION}",
      "ghost_element.hover": "#${COLOR_OVERLAY}",
      "ghost_element.selected": "#${COLOR_SELECTION}",
      "text": "#${COLOR_FG}",
      "text.muted": "#${COLOR_FG_SUBTLE}",
      "text.placeholder": "#${COLOR_FG_MUTED}",
      "text.disabled": "#${COLOR_FG_MUTED}",
      "text.accent": "#${COLOR_IRIS}",
      "icon": "#${COLOR_FG_SUBTLE}",
      "icon.accent": "#${COLOR_IRIS}",
      "editor.background": "#${COLOR_BG}",
      "editor.gutter.background": "#${COLOR_BG}",
      "editor.active_line.background": "#${COLOR_CURSOR_LINE}",
      "editor.line_number": "#${COLOR_FG_MUTED}",
      "editor.active_line_number": "#${COLOR_FG}",
      "editor.foreground": "#${COLOR_FG}",
      "search.match_background": "#${COLOR_SELECTION}",
      "terminal.background": "#${COLOR_BG}",
      "terminal.foreground": "#${COLOR_FG}",
      "terminal.ansi.black": "#${COLOR_BLACK}",
      "terminal.ansi.red": "#${COLOR_RED_N}",
      "terminal.ansi.green": "#${COLOR_GREEN_N}",
      "terminal.ansi.yellow": "#${COLOR_YELLOW_N}",
      "terminal.ansi.blue": "#${COLOR_BLUE_N}",
      "terminal.ansi.magenta": "#${COLOR_MAGENTA_N}",
      "terminal.ansi.cyan": "#${COLOR_CYAN_N}",
      "terminal.ansi.white": "#${COLOR_WHITE_N}",
      "error": "#${COLOR_RED}",
      "warning": "#${COLOR_GOLD}",
      "success": "#${COLOR_GREEN_N}",
      "info": "#${COLOR_FOAM}",
      "warning.background": "#${COLOR_GOLD}22",
      "warning.border": "#${COLOR_GOLD}66",
      "error.background": "#${COLOR_RED}22",
      "error.border": "#${COLOR_RED}66",
      "info.background": "#${COLOR_FOAM}22",
      "info.border": "#${COLOR_FOAM}66",
      "success.background": "#${COLOR_GREEN_N}22",
      "success.border": "#${COLOR_GREEN_N}66",
      "hint.background": "#${COLOR_IRIS}22",
      "hint.border": "#${COLOR_IRIS}66",
      "created": "#${COLOR_GREEN_N}",
      "created.background": "#${COLOR_GREEN_N}22",
      "modified": "#${COLOR_GOLD}",
      "modified.background": "#${COLOR_GOLD}22",
      "deleted": "#${COLOR_RED}",
      "deleted.background": "#${COLOR_RED}22",
      "conflict": "#${COLOR_ROSE}",
      "renamed": "#${COLOR_FOAM}",
      "ignored": "#${COLOR_FG_MUTED}",
      "hidden": "#${COLOR_FG_MUTED}",
      "hint": "#${COLOR_IRIS}",
      "predictive": "#${COLOR_FG_MUTED}",
      "scrollbar.thumb.background": "#${COLOR_SELECTION}88",
      "scrollbar.track.background": "#${COLOR_BG}",
      "scrollbar.track.border": "#${COLOR_BG}",
      "editor.indent_guide": "#${COLOR_OVERLAY}",
      "editor.indent_guide_active": "#${COLOR_BORDER}",
      "editor.wrap_guide": "#${COLOR_OVERLAY}",
      "editor.document_highlight.read_background": "#${COLOR_SELECTION}66",
      "players": [{ "cursor": "#${COLOR_IRIS}", "background": "#${COLOR_IRIS}", "selection": "#${COLOR_SELECTION}" }],
      "syntax": {
        "keyword": { "color": "#${COLOR_IRIS}" },
        "function": { "color": "#${COLOR_PINE}" },
        "string": { "color": "#${COLOR_GREEN_N}" },
        "number": { "color": "#${COLOR_ROSE}" },
        "constant": { "color": "#${COLOR_ROSE}" },
        "type": { "color": "#${COLOR_GOLD}" },
        "property": { "color": "#${COLOR_FOAM}" },
        "variable": { "color": "#${COLOR_FG}" },
        "operator": { "color": "#${COLOR_FG_SUBTLE}" },
        "punctuation": { "color": "#${COLOR_FG_SUBTLE}" },
        "comment": { "color": "#${COLOR_FG_MUTED}", "font_style": "italic" },
        "keyword.control": { "color": "#${COLOR_IRIS}" },
        "boolean": { "color": "#${COLOR_ROSE}" },
        "constructor": { "color": "#${COLOR_GOLD}" },
        "attribute": { "color": "#${COLOR_GOLD}" },
        "variable.special": { "color": "#${COLOR_RED}" },
        "string.escape": { "color": "#${COLOR_FOAM}" },
        "punctuation.bracket": { "color": "#${COLOR_FG_SUBTLE}" },
        "tag": { "color": "#${COLOR_IRIS}" }
      }
    }
  }]
}
EOF

# ── Symlinks (for tools that resolve includes relative to their config dir) ──
mkdir -p "${HOME}/.config/waybar" "${HOME}/.config/zathura" "${HOME}/.config/swayosd"
[ -L "${HOME}/.config/zathura/colors-zathura" ] || ln -sf "../colors/colors-zathura" "${HOME}/.config/zathura/colors-zathura"

echo "Colors generated from $COLORS"
