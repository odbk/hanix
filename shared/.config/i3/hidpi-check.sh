#!/usr/bin/env bash
# HaNiX — Detección HiDPI al arrancar i3

apply_hidpi() {
    xrdb -merge - <<EOF
Xft.dpi:        192
Xft.antialias:  1
Xft.hinting:    1
Xft.rgba:       rgb
Xft.lcdfilter:  lcddefault
Xcursor.size:   48
Xcursor.theme:  Bibata-Modern-Classic
EOF

    dbus-update-activation-environment --systemd \
        GDK_SCALE=2       \
        GDK_DPI_SCALE=0.5 \
        QT_SCALE_FACTOR=2 \
        XCURSOR_SIZE=48

    xsetroot -cursor_name left_ptr
}

scale_rasi() {
    [ -f /tmp/hanix-hidpi-rasi-scaled ] && return
    touch /tmp/hanix-hidpi-rasi-scaled
    RASI_DIR="$HOME/.config/polybar/scripts/rofi"
    for f in "$RASI_DIR"/*.rasi; do
        sed -i -E 's/("([^"]*) ([0-9]+)")/echo "\"\2 $((\3*2))\""/ge' "$f"
        sed -i -E 's/([0-9]+)px/echo "$((\1*2))px"/ge' "$f"
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
    -e 's/("([^"]*) ([0-9]+)")/echo "\"\2 $((\3*2))\""/ge' \
    -e 's/([0-9]+)px/echo "$((\1*2))px"/ge' \
    "$RASI_ORIG" > "$RASI"

CHOICE=$(echo -e "Sí, aplicar escalado HiDPI\nNo, mantener por defecto" | \
    rofi -no-config -theme "$RASI" \
    -dmenu -p "  Pantalla HiDPI detectada (${W}x${H})" -i)

[[ "$CHOICE" != "Sí"* ]] && exit 0

# ── Aplicar ────────────────────────────────────────────────────────────────
apply_hidpi
scale_rasi
touch /tmp/hanix-hidpi-active

# Reiniciar i3 — exec_always relanzará polybar con el entorno actualizado
i3-msg restart
