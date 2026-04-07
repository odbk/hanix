#!/usr/bin/env bash
cd ~/hanix || { echo "Error: no se encuentra ~/hanix"; read -r _; exit 1; }

nix flake update 2>&1

# Limpiar caché para que polybar refleje el estado real
rm -rf "/tmp/hanix-updates"

echo ""
read -r -p "¿Aplicar ahora con rebuild? [s/N] " CONFIRM
echo ""

if [[ "$CONFIRM" =~ ^[sS]$ ]]; then
    ~/hanix/rebuild
    echo ""
    read -r -p "Pulsa Enter para cerrar." _
else
    echo "Puedes aplicar más tarde con: rebuild"
    read -r -p "Pulsa Enter para cerrar." _
fi

# Refrescar módulo nixupdates sin reiniciar polybar
polybar-msg action "#nixupdates.hook.0" 2>/dev/null || true
