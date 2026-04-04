#!/usr/bin/env bash
# IP de la interfaz VPN activa (tun*, wg*)
# Envía notificación dunst al conectar/desconectar

STATE="/tmp/hanix-vpn-state"

for iface in tun0 tun1 tun2 wg0 wg1; do
    ip=$(ip addr show "$iface" 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    if [ -n "$ip" ]; then
        prev=$(cat "$STATE" 2>/dev/null)
        if [ "$prev" != "${iface}:${ip}" ]; then
            echo "${iface}:${ip}" > "$STATE"
            dunstify -u normal -i network-vpn "󰕥  VPN Conectada" "${iface}  →  ${ip}" &
        fi
        echo "󰕥 ${iface}: ${ip}"
        exit 0
    fi
done

# Sin VPN — notificar si acaba de desconectarse
if [ -f "$STATE" ]; then
    rm -f "$STATE"
    dunstify -u low -i network-offline "󰕥  VPN Desconectada" "" &
fi
