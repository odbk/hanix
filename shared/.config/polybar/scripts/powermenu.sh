#!/usr/bin/env bash

dir="$HOME/.config/polybar/scripts/rofi"
uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -no-config -theme $dir/powermenu.rasi"

shutdown="󰐥 Apagar"
reboot="󰜉 Reiniciar"
lock="󰌾 Bloquear"
suspend="󰒲 Suspender"
logout="󰍃 Cerrar sesión"

confirm_exit() {
    rofi -dmenu -no-config -i -no-fixed-num-lines \
        -p "¿Seguro? (y/n): " \
        -theme "$dir/confirm.rasi"
}

options="$logout\n$lock\n$suspend\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
case $chosen in
    $shutdown)
        ans=$(confirm_exit)
        [[ "$ans" =~ ^[yYsS] ]] && systemctl poweroff ;;
    $reboot)
        ans=$(confirm_exit)
        [[ "$ans" =~ ^[yYsS] ]] && systemctl reboot ;;
    $lock)
        i3lock ;;
    $suspend)
        ans=$(confirm_exit)
        [[ "$ans" =~ ^[yYsS] ]] && systemctl suspend ;;
    $logout)
        ans=$(confirm_exit)
        [[ "$ans" =~ ^[yYsS] ]] && i3-msg exit ;;
esac
