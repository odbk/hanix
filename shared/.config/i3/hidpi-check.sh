#!/usr/bin/env bash
# HaNiX — Detección HiDPI al arrancar i3

apply_hidpi() {
    xrdb -merge - <<EOF
Xft.dpi:        168
Xft.antialias:  1
Xft.hinting:    1
Xft.rgba:       rgb
Xft.lcdfilter:  lcddefault
Xcursor.size:   42
Xcursor.theme:  Bibata-Modern-Classic
EOF

    dbus-update-activation-environment --systemd \
        GDK_SCALE=1         \
        GDK_DPI_SCALE=1.75  \
        QT_SCALE_FACTOR=1.75 \
        XCURSOR_SIZE=42

    xsetroot -cursor_name left_ptr
}

scale_rasi() {
    [ -f /tmp/hanix-hidpi-rasi-scaled ] && return
    touch /tmp/hanix-hidpi-rasi-scaled
    for RASI_DIR in "$HOME/.config/polybar/scripts/rofi" "$HOME/.config/rofi"; do
        [ -d "$RASI_DIR" ] || continue
    for f in "$RASI_DIR"/*.rasi; do
        fname=$(basename "$f")
        [[ "$fname" == confirm.rasi || "$fname" == confirm-hidpi.rasi ]] && continue
        # Escalar valores px y tamaños de fuente ("Font Name 10" → "Font Name 18")
        awk '
        {
            # Escalar NNpx — construir salida sin reprocesar
            result = ""; rest = $0
            while (match(rest, /[0-9]+px/)) {
                result = result substr(rest, 1, RSTART-1) int(substr(rest, RSTART, RLENGTH-2)*1.75) "px"
                rest = substr(rest, RSTART+RLENGTH)
            }
            line = result rest
            # Escalar tamaño de fuente: "Font Name 10" → "Font Name 18"
            if (match(line, /"[^"]*[[:space:]][0-9]+"/, arr)) {
                quoted = substr(line, RSTART, RLENGTH)
                n = split(substr(quoted, 2, length(quoted)-2), parts, " ")
                size = parts[n] + 0
                if (size > 0) {
                    parts[n] = int(size * 1.75)
                    new = parts[1]
                    for (i=2; i<=n; i++) new = new " " parts[i]
                    sub(/"[^"]*[[:space:]][0-9]+"/, "\"" new "\"", line)
                }
            }
            print line
        }
        ' "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
    done
    done
}

restart_dunst() {
    DUNSTRC="$HOME/.config/dunst/dunstrc"
    [ -f "$DUNSTRC" ] || return
    kill $(pgrep dunst) 2>/dev/null || true
    sleep 0.3
    # Lanzar dunst con fuente escalada (10 → 18)
    sed 's/\(font.*\b\)\([0-9]\+\)\s*$/\115/' "$DUNSTRC" > /tmp/dunstrc-hidpi
    dunst -conf /tmp/dunstrc-hidpi &
}

# ── Si ya se aceptó HiDPI en este boot, reaplicar silenciosamente ──────────
if [ -f /tmp/hanix-hidpi-active ]; then
    apply_hidpi
    scale_rasi
    exit 0
fi

# ── "No mostrar más" — marcador persistente entre reinicios ───────────────
[ -f "$HOME/.config/hanix-hidpi-dismissed" ] && exit 0

# ── Primera vez por sesión — comprobar si ya se preguntó ──────────────────
[ -f /tmp/hanix-hidpi-checked ] && exit 0
touch /tmp/hanix-hidpi-checked

# ── Resolución del monitor principal ──────────────────────────────────────
PRIMARY_LINE=$(xrandr | grep -m1 ' connected primary')
[ -z "$PRIMARY_LINE" ] && PRIMARY_LINE=$(xrandr | grep -m1 ' connected')
[ -z "$PRIMARY_LINE" ] && exit 0

W=$(echo "$PRIMARY_LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP '^\d+')
H=$(echo "$PRIMARY_LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP 'x\K\d+')
[ -z "$W" ] || [ -z "$H" ] && exit 0

[ "$W" -ge 2560 ] && [ "$H" -ge 1440 ] || exit 0

# ── Detectar DPI del monitor para elegir tamaño del modal ─────────────────
WIDTH_MM=$(echo "$PRIMARY_LINE" | grep -oP '\d+mm' | head -1 | grep -oP '\d+')
if [ -n "$WIDTH_MM" ] && [ "$WIDTH_MM" -gt 0 ]; then
    MODAL_DPI=$(( W * 254 / (WIDTH_MM * 10) ))
else
    MODAL_DPI=96
fi

# Usar rasi pre-escalado si el monitor es HiDPI
RASI_DIR="$HOME/.config/polybar/scripts/rofi"
if [ "$MODAL_DPI" -ge 144 ] && [ -f "$RASI_DIR/confirm-hidpi.rasi" ]; then
    RASI="$RASI_DIR/confirm-hidpi.rasi"
else
    RASI="$RASI_DIR/confirm.rasi"
fi

# ── Modal ─────────────────────────────────────────────────────────────────
CHOICE=$(printf "  Sí.\n  No.\n  No recordar más." | rofi -no-config -theme "$RASI" \
    -dmenu -p "󰹑  HiDPI (${W}×${H}) detectado — ¿Ampliar escalado a 1.75×?" \
    -i)

if [[ "$CHOICE" == *"No recordar"* ]]; then
    touch "$HOME/.config/hanix-hidpi-dismissed"
    exit 0
fi

[[ "$CHOICE" != *"Sí"* ]] && exit 0

# ── Aplicar ────────────────────────────────────────────────────────────────
apply_hidpi
scale_rasi
restart_dunst
touch /tmp/hanix-hidpi-active

# Relanzar polybar con config-hidpi.ini
kill $(pgrep polybar) 2>/dev/null || true
sleep 0.5
while pgrep polybar > /dev/null; do sleep 0.1; done
exec bash ~/.config/polybar/launch.sh
