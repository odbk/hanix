#!/usr/bin/env bash
# Popup hackstyle de uso de disco

G='\033[1;32m'   # verde brillante
C='\033[0;36m'   # cyan
D='\033[0;90m'   # gris oscuro
R='\033[0m'

clear
echo -e "${G}"
echo -e "  ╔══════════════════════════════════════════════════════╗"
echo -e "  ║           󰋊  DISK USAGE  ──  HaNiX                  ║"
echo -e "  ╠══════════════╦═══════════╦═══════════╦═══════════════╣"
printf  "  ║${C}  %-12s${G}║${C}  %-9s${G}║${C}  %-9s${G}║${C}  %-13s${G}║\n" "MOUNT" "TOTAL" "USED" "FREE (USE%)"
echo -e "  ╠══════════════╬═══════════╬═══════════╬═══════════════╣"

print_row() {
    local mp="$1"
    if ! df -h "$mp" &>/dev/null; then return; fi
    read -r _ total used free pct _ < <(df -h "$mp" | tail -1)
    printf "  ║${C}  %-12s${G}║  %-9s║  %-9s║  %-13s║\n" "$mp" "$total" "$used" "$free ($pct)"
}

for mp in / /home /boot; do
    print_row "$mp"
done

echo -e "  ╚══════════════╩═══════════╩═══════════╩═══════════════╝"
echo -e "${D}"
echo -e "  [ pulsa cualquier tecla para cerrar ]"
echo -e "${R}"
read -n1 -s
