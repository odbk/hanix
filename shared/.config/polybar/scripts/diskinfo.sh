#!/usr/bin/env bash
# Popup de uso de disco via rofi

dir="$HOME/.config/polybar/scripts/rofi"

G='#00ff41'   # verde
D='#1a6b1a'   # verde oscuro
W='#cdd6f4'   # blanco suave

row() {
    local mp="$1"
    if ! df -h "$mp" &>/dev/null; then return; fi
    read -r _ total used free pct _ < <(df -h "$mp" | tail -1)
    printf '<span color="%s">  %-8s</span><span color="%s">│</span><span color="%s"> %-8s </span><span color="%s">│</span><span color="%s"> %-8s </span><span color="%s">│</span><span color="%s"> %-8s </span><span color="%s">│</span><span color="%s"> %s</span>\n' \
        "$W" "$mp" "$D" "$G" "$total" "$D" "$G" "$used" "$D" "$G" "$free" "$D" "$G" "$pct"
}

SEP="<span color='${D}'>  ────────┼──────────┼──────────┼──────────┼──────</span>"
HDR="<span color='${D}'>  <b>MOUNT   </b></span><span color='${D}'>│</span><span color='${D}'> <b>TOTAL   </b> </span><span color='${D}'>│</span><span color='${D}'> <b>USED    </b> </span><span color='${D}'>│</span><span color='${D}'> <b>FREE    </b> </span><span color='${D}'>│</span><span color='${D}'> <b>USE%</b></span>"

TITLE="<span color='${G}'><b>󰋊  DISK USAGE</b></span>"
BLANK="<span> </span>"

MSG="${TITLE}\n${BLANK}\n${HDR}\n${SEP}"
for mp in / /home /boot; do
    line=$(row "$mp")
    [ -n "$line" ] && MSG="${MSG}\n${line}"
done
MSG="${MSG}\n${SEP}"

rofi -no-config \
     -theme "$dir/diskinfo.rasi" \
     -e "$MSG"
