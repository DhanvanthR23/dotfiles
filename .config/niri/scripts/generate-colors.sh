#!/usr/bin/env bash
# generate-colors.sh — propagate colors.conf to all tool configs
set -euo pipefail

COLORS="${XDG_CONFIG_HOME:-$HOME/.config}/colors/colors.conf"
if [[ ! -f "$COLORS" ]]; then
  echo "ERROR: $COLORS not found" >&2; exit 1
fi
source "$COLORS"

OUT="${XDG_CONFIG_HOME:-$HOME/.config}/colors"
mkdir -p "$OUT"

# ── Niri (KDL) ───────────────────────────────────────────────────────────────
cat > "$OUT/colors.kdl" << EOF
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

# ── Waybar CSS (@define-color) ───────────────────────────────────────────────
cat > "$OUT/colors.css" << EOF
@define-color bg           #${COLOR_BG};
@define-color surface      #${COLOR_SURFACE};
@define-color overlay      #${COLOR_OVERLAY};
@define-color border       #${COLOR_BORDER};
@define-color selection    #${COLOR_SELECTION};
@define-color cursor-line  #${COLOR_CURSOR_LINE};
@define-color fg           #${COLOR_FG};
@define-color fg-subtle    #${COLOR_FG_SUBTLE};
@define-color fg-muted     #${COLOR_FG_MUTED};
@define-color red          #${COLOR_RED};
@define-color rose         #${COLOR_ROSE};
@define-color gold         #${COLOR_GOLD};
@define-color pine         #${COLOR_PINE};
@define-color foam         #${COLOR_FOAM};
@define-color iris         #${COLOR_IRIS};
EOF

# ── Waybar JSONC (calendar colors) ───────────────────────────────────────────
cat > "$OUT/colors-waybar.jsonc" << EOF
{
  "calendar": {
    "format": {
      "months": "<span color='#${COLOR_FG}'><b>{}</b></span>",
      "days": "<span color='#${COLOR_FG_SUBTLE}'>{}</span>",
      "today": "<span color='#${COLOR_PINE}'><b>{}</b></span>"
    }
  }
}
EOF

# ── Mako ─────────────────────────────────────────────────────────────────────
cat > "$OUT/colors-mako.ini" << EOF
background-color=#${COLOR_BG}ee
text-color=#${COLOR_FG}
border-color=#${COLOR_FG_MUTED}

[urgency=low]
background-color=#${COLOR_BG}cc
text-color=#${COLOR_FG_MUTED}
border-color=#${COLOR_FG_MUTED}

[urgency=normal]
background-color=#${COLOR_BG}ee
text-color=#${COLOR_FG}
border-color=#${COLOR_FG_MUTED}

[urgency=high]
background-color=#${COLOR_BG}
text-color=#${COLOR_RED}
border-color=#${COLOR_RED}
border-size=2

[app-name=Spotify]
border-color=#${COLOR_FOAM}

[app-name=Jellyfin]
border-color=#${COLOR_PINE}
EOF

# ── Foot ─────────────────────────────────────────────────────────────────────
cat > "$OUT/colors-foot.ini" << EOF
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
cat > "$OUT/colors-fuzzel.ini" << EOF
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

# ── Hyprlock (hyprlang vars) ─────────────────────────────────────────────────
cat > "$OUT/colors-hypr.conf" << EOF
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

cat > "$QT_DIR/RosePine.colors" << EOF
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
GTK_COLORS_CONTENT="@define-color theme_bg_color #${COLOR_BG};
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

echo "$GTK_COLORS_CONTENT" > "${HOME}/.config/gtk-3.0/colors"
echo "$GTK_COLORS_CONTENT" > "${HOME}/.config/gtk-4.0/colors"

echo "Colors generated from $COLORS"
