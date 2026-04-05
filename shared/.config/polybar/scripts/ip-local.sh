#!/usr/bin/env bash
# IP de la interfaz con ruta por defecto
iface=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+')
ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+')
[ -n "$ip" ] && echo " ${iface}: ${ip}"
