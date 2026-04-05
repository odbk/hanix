#!/usr/bin/env bash

# Evitar ejecuciones simultáneas en restart de i3
LOCKFILE="/tmp/polybar-launch.lock"
exec 9>"$LOCKFILE"
flock -n 9 || exit 0

killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do sleep 0.1; done

# Establecer el monitor más ancho como primary si no hay ninguno marcado
if ! xrandr --query | grep -q ' connected primary'; then
    WIDEST=$(xrandr | grep ' connected' | while read -r LINE; do
        NAME=$(echo "$LINE" | awk '{print $1}')
        W=$(echo "$LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP '^\d+')
        [ -n "$W" ] && echo "$W $NAME"
    done | sort -rn | head -1 | awk '{print $2}')
    [ -n "$WIDEST" ] && xrandr --output "$WIDEST" --primary
fi

CFG="$HOME/.config/polybar/config.ini"
[ -f /tmp/hanix-hidpi-active ] && CFG="$HOME/.config/polybar/config-hidpi.ini"

PRIMARY=$(xrandr --query | grep ' connected primary' | awk '{print $1}')

for m in $(xrandr --query | grep ' connected' | awk '{print $1}'); do
    if [ "$m" = "$PRIMARY" ]; then
        MONITOR=$m polybar --reload primary        -c "$CFG" &
        MONITOR=$m polybar --reload bottom-primary -c "$CFG" &
    else
        MONITOR=$m polybar --reload secondary        -c "$CFG" &
        MONITOR=$m polybar --reload bottom-secondary -c "$CFG" &
    fi
done

# Reiniciar applets de bandeja para que se suscriban a la nueva tray
sleep 1
killall -q nm-applet blueman-applet 2>/dev/null || true
nm-applet &
blueman-applet &
