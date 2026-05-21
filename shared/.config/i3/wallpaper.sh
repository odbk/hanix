#!/usr/bin/env bash
# Establece el monitor primario (el más ancho) y aplica el wallpaper.
# Soporta cualquier número de monitores activos.

# ── 1. Marcar como primary el monitor más ancho ──────────────
WIDEST=$(xrandr | grep ' connected' | while read -r LINE; do
  NAME=$(echo "$LINE" | awk '{print $1}')
  W=$(echo "$LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP '^\d+')
  [ -n "$W" ] && echo "$W $NAME"
done | sort -rn | head -1 | awk '{print $2}')
[ -n "$WIDEST" ] && xrandr --output "$WIDEST" --primary

# ── 1b. Activar outputs conectados sin modo (ej: tercer monitor en iGPU) ─
_REF=$(xrandr | grep ' connected' | \
  awk '{for(i=1;i<=NF;i++) if($i~/[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/){split($i,p,"+"); print p[2]" "$1; break}}' | \
  sort -rn | head -1 | awk '{print $2}')
[ -z "$_REF" ] && _REF="$WIDEST"
for _OUT in $(xrandr | grep ' connected' | grep -v '+[0-9]' | awk '{print $1}'); do
  xrandr --output "$_OUT" --auto --right-of "$_REF" 2>/dev/null || true
done

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
