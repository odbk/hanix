#!/usr/bin/env bash
BAT=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^BAT' | head -1)
[ -z "$BAT" ] && exit 0

STATUS=$(cat /sys/class/power_supply/$BAT/status 2>/dev/null)
PCT=$(cat /sys/class/power_supply/$BAT/capacity 2>/dev/null)

icon() {
    local p=$1
    if   [ "$p" -le 20 ]; then echo "󰁺"
    elif [ "$p" -le 40 ]; then echo "󰁻"
    elif [ "$p" -le 60 ]; then echo "󰁽"
    elif [ "$p" -le 80 ]; then echo "󰁿"
    else echo "󰁹"
    fi
}

case "$STATUS" in
    Charging)    echo "󰂄 ${PCT}%" ;;
    Full)        echo "󰁹" ;;
    Discharging) echo "$(icon $PCT) ${PCT}%" ;;
    *)           echo "$(icon ${PCT:-0}) ${PCT}%" ;;
esac
