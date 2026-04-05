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
    RASI_DIR="$HOME/.config/polybar/scripts/rofi"
    for f in "$RASI_DIR"/*.rasi; do
        # Fuentes: "Font Name 10" → "Font Name 18"  (×1.75 redondeado)
        sed -i -E 's/("([^"]*) ([0-9]+)")/printf "%s" "\""; printf "%s" "\2 "; echo $(( (\3 * 175 + 50) / 100 )); printf "%s" "\""/ge' "$f" 2>/dev/null || \
        sed -i -E 's/("([^"]*) ([0-9]+)")/echo "\"\2 $(( (\3 * 175 + 50) \/ 100 ))\""/ge' "$f"
        # Valores px: 350px → 612px
        sed -i -E 's/([0-9]+)px/echo "$(( (\1 * 175 + 50) \/ 100 ))px"/ge' "$f"
    done
}

# ── Si ya se aceptó HiDPI en este boot, reaplicar silenciosamente ──────────
if [ -f /tmp/hanix-hidpi-active ]; then
    apply_hidpi
    scale_rasi
    exit 0
fi

# ── Primera vez — comprobar si ya se preguntó ──────────────────────────────
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

# ── Modal — generar confirm.rasi escalado para que se vea en HiDPI ─────────
RASI_ORIG="$HOME/.config/polybar/scripts/rofi/confirm.rasi"
RASI="/tmp/hidpi-confirm.rasi"
sed -E \
    -e 's/("([^"]*) ([0-9]+)")/echo "\"\2 $(( (\3 * 175 + 50) \/ 100 ))\""/ge' \
    -e 's/([0-9]+)px/echo "$(( (\1 * 175 + 50) \/ 100 ))px"/ge' \
    "$RASI_ORIG" > "$RASI"

CHOICE=$(echo -e "Sí, aplicar escalado HiDPI\nNo, mantener por defecto" | \
    rofi -no-config -theme "$RASI" \
    -dmenu -p "  Pantalla HiDPI detectada (${W}x${H})" -i)

[[ "$CHOICE" != "Sí"* ]] && exit 0

# ── Aplicar ────────────────────────────────────────────────────────────────
apply_hidpi
scale_rasi
touch /tmp/hanix-hidpi-active

# Reiniciar i3 — exec_always relanzará polybar con config-hidpi.ini
i3-msg restart
