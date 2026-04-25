#!/usr/bin/env bash
cd ~/hanix || { echo "Error: no se encuentra ~/hanix"; read -r _; exit 1; }

echo "Comprobando actualizaciones..."
OLD_LOCK=$(cat flake.lock)
nix flake update 2>&1
NEW_LOCK=$(cat flake.lock)

# Actualizar caché con revs actuales para que polybar muestre 0
CACHE_DIR="/tmp/hanix-updates"
mkdir -p "$CACHE_DIR"
for node in nixpkgs unstable nixvim; do
    rev=$(jq -r ".nodes.\"$node\".locked.rev // empty" ~/hanix/flake.lock 2>/dev/null)
    [ -n "$rev" ] && echo "$rev" > "$CACHE_DIR/$node"
done

# Si no cambió nada, salir sin preguntar
if [ "$OLD_LOCK" = "$NEW_LOCK" ]; then
    echo ""
    echo "✓ Todo al día, no hay nada nuevo."
    polybar-msg action "#nixupdates.hook.0" 2>/dev/null || true
    sleep 2
    exit 0
fi

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

