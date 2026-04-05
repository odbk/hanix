#!/usr/bin/env bash
# HaNiX — Cheatsheet modal

DIR="$HOME/.config/polybar/scripts/rofi"
G='#00ff41'
D='#1a6b1a'
W='#cdd6f4'
S='#585b70'

# Ancho fijo de la columna izquierda (caracteres monospace)
COL=24

h() {
    printf '<span color="%s"><b>▸ %s</b></span>\n' "$G" "$1"
}
row() {
    local key="$1" desc="$2"
    local padded
    padded=$(printf "%-${COL}s" "$key")
    printf '  <span color="%s">%s</span><span color="%s">%s</span>\n' \
        "$G" "$padded" "$W" "$desc"
}
sep() {
    printf '<span color="%s">%s</span>\n' "$S" \
        "────────────────────────────────────────────────────"
}

MSG=""
MSG+="$(sep)"$'\n'
MSG+="$(h 'i3 — VENTANAS')"$'\n'
MSG+="$(row 'mod + Return'         'Terminal')"$'\n'
MSG+="$(row 'mod + q'              'Cerrar ventana')"$'\n'
MSG+="$(row 'mod + f'              'Fullscreen')"$'\n'
MSG+="$(row 'mod + d'              'Lanzador de apps')"$'\n'
MSG+="$(row 'mod + h / v'          'Split horizontal / vertical')"$'\n'
MSG+="$(row 'mod + Space'          'Toggle tiling / floating')"$'\n'
MSG+="$(row 'mod + Shift+Space'    'Flotar ventana activa')"$'\n'
MSG+="$(row 'mod + flechas'        'Mover foco')"$'\n'
MSG+="$(row 'mod + Shift+flechas'  'Mover ventana')"$'\n'
MSG+="$(row 'mod + 1-0'            'Cambiar workspace')"$'\n'
MSG+="$(row 'mod + Shift+1-0'      'Mover ventana a workspace')"$'\n'

MSG+="$(sep)"$'\n'
MSG+="$(h 'i3 — SISTEMA')"$'\n'
MSG+="$(row 'mod + Escape'         'Bloquear pantalla')"$'\n'
MSG+="$(row 'mod + Shift+c'        'Recargar config i3')"$'\n'
MSG+="$(row 'mod + Shift+r'        'Reiniciar i3')"$'\n'
MSG+="$(row 'mod + Shift+e'        'Cerrar sesion')"$'\n'

MSG+="$(sep)"$'\n'
MSG+="$(h 'CAPTURAS')"$'\n'
MSG+="$(row 'Print'                'Captura completa a ~/Images')"$'\n'
MSG+="$(row 'mod + p'              'Area al portapapeles')"$'\n'
MSG+="$(row 'mod + Shift+p'        'Captura con anotaciones')"$'\n'

MSG+="$(sep)"$'\n'
MSG+="$(h 'HACKING — TERMINAL')"$'\n'
MSG+="$(row 'ports {ip} [args]'    'nmap -sV --open -T4')"$'\n'
MSG+="$(row 'http [puerto]'        'Servidor HTTP (def: 8080)')"$'\n'
MSG+="$(row 'b64e {texto}'         'Codificar Base64')"$'\n'
MSG+="$(row 'b64d {texto}'         'Decodificar Base64')"$'\n'
MSG+="$(row 'urle / urld'          'URL encode / decode (stdin)')"$'\n'
MSG+="$(row 'vpnip'                'IP de la VPN (tun/wg)')"$'\n'
MSG+="$(row 'myip'                 'IP publica (ifconfig.me)')"$'\n'

MSG+="$(sep)"$'\n'
MSG+="$(h 'TERMINAL — ATAJOS')"$'\n'
MSG+="$(row 'Ctrl + R'             'Busqueda fuzzy en historial')"$'\n'
MSG+="$(row 'Ctrl + T'             'Buscar archivos con fzf')"$'\n'
MSG+="$(row 'Alt + C'              'Navegar directorios con fzf')"$'\n'
MSG+="$(row 'flecha derecha'       'Aceptar autosugerencia')"$'\n'
MSG+="$(row 'Tab'                  'Autocompletar')"$'\n'

MSG+="$(sep)"$'\n'
MSG+="$(h 'POLYBAR — CLICKS')"$'\n'
MSG+="$(row 'Click IP local / VPN' 'Copia al portapapeles')"$'\n'
MSG+="$(row 'Click disco'          'Modal de uso de disco')"$'\n'
MSG+="$(row 'Click power'          'Menu apagar/reiniciar/bloquear')"$'\n'
MSG+="$(row 'Click updates'        'Actualizar flake + rebuild')"$'\n'
MSG+="$(sep)"

rofi -no-config -theme "$DIR/cheatsheet.rasi" \
     -dmenu -mesg "$MSG" -p "" < /dev/null
