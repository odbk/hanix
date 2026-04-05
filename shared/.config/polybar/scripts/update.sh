#!/usr/bin/env bash
cd ~/hanix || { echo "Error: no se encuentra ~/hanix"; read -r _; exit 1; }
nix flake update 2>&1
echo ""
read -r -p "Pulsa Enter para cerrar." _
