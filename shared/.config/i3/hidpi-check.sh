#!/usr/bin/env bash
# HaNiX — Detección HiDPI al arrancar i3
# Si la resolución es alta (≥2560x1440) y el DPI es el default (96),
# probablemente es una pantalla HiDPI sin datos EDID → ofrecer 2x scaling.

# Evitar que salte más de una vez por sesión
[ -f /tmp/hanix-hidpi-checked ] && exit 0
touch /tmp/hanix-hidpi-checked

# Resolución del monitor principal
PRIMARY_LINE=$(xrandr | grep -m1 ' connected primary')
[ -z "$PRIMARY_LINE" ] && PRIMARY_LINE=$(xrandr | grep -m1 ' connected')
[ -z "$PRIMARY_LINE" ] && exit 0

W=$(echo "$PRIMARY_LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP '^\d+')
H=$(echo "$PRIMARY_LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP 'x\K\d+')

[ -z "$W" ] || [ -z "$H" ] && exit 0

# Solo actuar si la resolución es suficientemente alta
[ "$W" -ge 2560 ] && [ "$H" -ge 1440 ] || exit 0

RASI="$HOME/.config/polybar/scripts/rofi/confirm.rasi"

CHOICE=$(echo -e "Sí, aplicar escalado HiDPI\nNo, mantener por defecto" | \
    rofi -no-config -theme "$RASI" \
    -dmenu -p "  Pantalla HiDPI detectada (${W}x${H})" -i)

[[ "$CHOICE" != "Sí"* ]] && exit 0

# Aplicar escalado 2x
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
    GDK_SCALE=2           \
    GDK_DPI_SCALE=0.5     \
    QT_SCALE_FACTOR=2     \
    XCURSOR_SIZE=48

export XCURSOR_SIZE=48

# Aplicar cursor inmediatamente
xsetroot -cursor_name left_ptr

# Escalar ficheros .rasi de rofi en sitio (sesión efímera en ISO)
RASI_DIR="$HOME/.config/polybar/scripts/rofi"
for f in "$RASI_DIR"/*.rasi; do
    # Doblar tamaños de fuente:  "Font Name 18"  →  "Font Name 36"
    sed -i -E 's/("([^"]*) ([0-9]+)")/echo "\"\2 $((\3*2))\""/ge' "$f"
    # Doblar valores en px:  350px  →  700px
    sed -i -E 's/([0-9]+)px/echo "$((\1*2))px"/ge' "$f"
done

# Marcar sesión HiDPI para que launch.sh escale polybar
touch /tmp/hanix-hidpi-active

# Reiniciar i3 — exec_always relanzará polybar con el entorno actualizado
i3-msg restart
