#!/usr/bin/env bash
# Establece el monitor primario (el más ancho) y aplica el wallpaper.
# Usa fondows1080.png en monitores ultrawide (ratio > 2:1), wallpaper.png en el resto.

# ── 1. Marcar como primary el monitor más ancho ──────────────
WIDEST=$(xrandr | grep ' connected' | while read -r LINE; do
  NAME=$(echo "$LINE" | awk '{print $1}')
  W=$(echo "$LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP '^\d+')
  [ -n "$W" ] && echo "$W $NAME"
done | sort -rn | head -1 | awk '{print $2}')
[ -n "$WIDEST" ] && xrandr --output "$WIDEST" --primary

# ── 2. Elegir wallpaper según ratio del monitor primary ───────
PRIMARY=$(xrandr | grep -m1 ' connected primary' | awk '{print $1}')
PRIMARY_RES=$(xrandr | grep -m1 ' connected primary' | grep -oP '\d+x\d+\+\d+\+\d+' | head -1)
PW=$(echo "$PRIMARY_RES" | grep -oP '^\d+')
PH=$(echo "$PRIMARY_RES" | grep -oP '(?<=x)\d+')

WALL_WIDE="$HOME/.config/fondows1080.png"
WALL_STD="$HOME/.config/wallpaper.png"

# Ultrawide: ratio ancho/alto > 2 (ej: 3440x1440 = 2.38, 2560x1080 = 2.37)
if [ -n "$PW" ] && [ -n "$PH" ] && [ "$PH" -gt 0 ] && [ $(( PW * 10 / PH )) -gt 20 ] && [ -f "$WALL_WIDE" ]; then
    WALL_PRIMARY="$WALL_WIDE"
else
    WALL_PRIMARY="$WALL_STD"
fi

[ -f "$WALL_PRIMARY" ] || exit 0

SECONDARY=$(xrandr | grep ' connected' | grep -v ' primary' | awk '{print $1}' | head -1)

if [ -n "$PRIMARY" ] && [ -n "$SECONDARY" ] && [ "$PRIMARY" != "$SECONDARY" ]; then
    xwallpaper --output "$PRIMARY"   --maximize "$WALL_PRIMARY" \
               --output "$SECONDARY" --zoom     "$WALL_STD"
else
    xwallpaper --maximize "$WALL_PRIMARY"
fi
