#!/usr/bin/env bash

dir="$HOME/.config/polybar/scripts/rofi"
uptime=$(uptime -p | sed -e 's/up //g')

shutdown="󰐥  Apagar"
reboot="󰜉  Reiniciar"
lock="󰌾  Bloquear"
suspend="󰒲  Suspender"
logout="󰍃  Cerrar sesión"

confirm() {
    printf "  Sí.\n  No." | rofi -no-config -theme "$dir/confirm.rasi" \
        -dmenu -p "󰋔  ¿Seguro?" -i
}

options="$logout\n$lock\n$suspend\n$reboot\n$shutdown"

chosen="$(printf "%b" "$options" | rofi -no-config -theme "$dir/powermenu.rasi" \
    -dmenu -p "  $uptime" -selected-row 0)"

case $chosen in
    "$shutdown")
        [[ "$(confirm)" == *"Sí"* ]] && systemctl poweroff ;;
    "$reboot")
        [[ "$(confirm)" == *"Sí"* ]] && systemctl reboot ;;
    "$lock")
        bash "$HOME/.config/polybar/scripts/lockscreen.sh" ;;
    "$suspend")
        [[ "$(confirm)" == *"Sí"* ]] && systemctl suspend ;;
    "$logout")
        [[ "$(confirm)" == *"Sí"* ]] && i3-msg exit ;;
esac
