#!/usr/bin/env bash
# IP de la interfaz VPN activa (tun*, wg*)
for iface in tun0 tun1 tun2 wg0 wg1; do
    ip=$(ip addr show "$iface" 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    if [ -n "$ip" ]; then
        echo "󰕥 ${iface}: ${ip}"
        exit 0
    fi
done
