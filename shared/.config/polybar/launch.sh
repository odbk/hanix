#!/usr/bin/env bash

rm -f /tmp/polybar-launch.lock

kill $(pgrep polybar) 2>/dev/null || true
sleep 0.5
while pgrep polybar > /dev/null; do sleep 0.1; done

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

# Detección automática de batería
BATTERY_NAME=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^BAT' | head -1)
ADAPTER_NAME=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^(AC|ADP|ACAD|USB)' | head -1)
if [ -n "$BATTERY_NAME" ]; then
    export BATTERY_MODULES=" sep battery"
    export POLYBAR_BATTERY="$BATTERY_NAME"
    export POLYBAR_ADAPTER="${ADAPTER_NAME:-AC}"
else
    export BATTERY_MODULES=""
    export POLYBAR_BATTERY="BAT0"
    export POLYBAR_ADAPTER="AC"
fi

PRIMARY=$(xrandr --query | grep ' connected primary' | awk '{print $1}')

for m in $(xrandr --query | grep ' connected' | awk '{print $1}'); do
    if [ "$m" = "$PRIMARY" ]; then
        MONITOR=$m polybar primary        -c "$CFG" &
        MONITOR=$m polybar bottom-primary -c "$CFG" &
    else
        MONITOR=$m polybar secondary        -c "$CFG" &
        MONITOR=$m polybar bottom-secondary -c "$CFG" &
    fi
done

# Reiniciar applets de bandeja para que se suscriban a la nueva tray
sleep 1
killall -q nm-applet blueman-applet 2>/dev/null || true
nm-applet &
blueman-applet &
