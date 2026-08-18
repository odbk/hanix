#!/usr/bin/env bash
# Cola de impresión para polybar.
#   click-izq → ver estado/cola en vivo (alacritty + watch)
#   click-der → cancelar todos los trabajos
ICON="󰐪"

# Impresora por defecto (vacío si no hay ninguna configurada)
DEF=$(lpstat -d 2>/dev/null | sed -n 's/.*: *//p')

if [ -z "$DEF" ]; then
  echo "%{F#888888}$ICON%{F-}"      # sin impresora → icono atenuado
  exit 0
fi

# ¿Deshabilitada / parada? (ES + EN)
if lpstat -p "$DEF" 2>/dev/null | grep -qiE "disabled|desactivad|deshabilit|parada|stopped"; then
  echo "$ICON!"
  exit 0
fi

# Nº de trabajos en cola
N=$(lpstat -o 2>/dev/null | grep -c .)
if [ "$N" -gt 0 ]; then
  echo "$ICON $N"
else
  echo "$ICON"
fi
