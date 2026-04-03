#!/usr/bin/env bash
# Estado bluetooth para polybar
# Click izquierdo → abre blueman-manager

POWERED=$(bluetoothctl show 2>/dev/null | grep "Powered: yes")

if [ -z "$POWERED" ]; then
  echo "󰂲 off"
  exit 0
fi

# Buscar dispositivo conectado
CONNECTED=$(bluetoothctl info 2>/dev/null | grep "Connected: yes")
if [ -n "$CONNECTED" ]; then
  NAME=$(bluetoothctl info 2>/dev/null | grep "Name:" | head -1 | sed 's/.*Name: //')
  echo "󰂱 ${NAME:-BT}"
else
  echo "󰂯"
fi
