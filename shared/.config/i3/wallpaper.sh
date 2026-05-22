#!/usr/bin/env bash
# Aplica layout de monitores (si existe) y wallpaper a todos los outputs activos.

# ── Layout específico de esta máquina ────────────────────────
[ -f "$HOME/.config/i3/monitor-setup.sh" ] && bash "$HOME/.config/i3/monitor-setup.sh"

# ── 2. Elegir wallpaper según ratio del monitor primary ───────
PRIMARY=$(xrandr | grep -m1 ' connected primary' | awk '{print $1}')
PRIMARY_RES=$(xrandr | grep -m1 ' connected primary' | grep -oP '\d+x\d+\+\d+\+\d+' | head -1)
PW=$(echo "$PRIMARY_RES" | grep -oP '^\d+')
PH=$(echo "$PRIMARY_RES" | grep -oP '(?<=x)\d+')

WALL_WIDE="$HOME/.config/fondows1080.png"
WALL_STD="$HOME/.config/wallpaper.png"

if [ -n "$PW" ] && [ -n "$PH" ] && [ "$PH" -gt 0 ] && [ $(( PW * 10 / PH )) -gt 20 ] && [ -f "$WALL_WIDE" ]; then
    WALL_PRIMARY="$WALL_WIDE"
else
    WALL_PRIMARY="$WALL_STD"
fi

[ -f "$WALL_PRIMARY" ] || exit 0

# ── 3. Aplicar wallpaper a todos los monitores activos ───────
XWALL_ARGS=()
while IFS= read -r MON; do
    if [ "$MON" = "$PRIMARY" ]; then
        XWALL_ARGS+=(--output "$MON" --zoom "$WALL_PRIMARY")
    else
        XWALL_ARGS+=(--output "$MON" --zoom "$WALL_STD")
    fi
done < <(xrandr | grep ' connected' | grep '+[0-9]' | awk '{print $1}')

[ ${#XWALL_ARGS[@]} -gt 0 ] && xwallpaper "${XWALL_ARGS[@]}"
