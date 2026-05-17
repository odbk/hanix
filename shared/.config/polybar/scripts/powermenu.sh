#!/usr/bin/env bash

dir="$HOME/.config/polybar/scripts/rofi"
uptime=$(uptime -p | sed 's/up //')

chosen=$(printf '󰐥  Apagar\n󰜉  Reiniciar\n󰒲  Suspender\n󰌾  Bloquear\n󰍃  Salir' | \
  rofi -no-config -theme "$dir/powermenu.rasi" \
    -dmenu -p "  $uptime" -selected-row 0)

case "$chosen" in
    *Apagar*)   systemctl poweroff ;;
    *Reiniciar*)systemctl reboot ;;
    *Suspender*)systemctl suspend ;;
    *Bloquear*) bash "$HOME/.config/polybar/scripts/lockscreen.sh" ;;
    *Salir*)    i3-msg exit ;;
esac
