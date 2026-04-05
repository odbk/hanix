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
Xft.dpi:       192
Xft.antialias: 1
Xft.hinting:   1
Xft.rgba:      rgb
Xft.lcdfilter: lcddefault
EOF

dbus-update-activation-environment --systemd \
    GDK_SCALE=2           \
    GDK_DPI_SCALE=0.5     \
    QT_SCALE_FACTOR=2     \
    XCURSOR_SIZE=48

# Reiniciar i3 para que las apps nuevas hereden el entorno
i3-msg restart
