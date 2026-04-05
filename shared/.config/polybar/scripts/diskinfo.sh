#!/usr/bin/env bash
dir="$HOME/.config/polybar/scripts/rofi"

G='#00ff41'
D='#4a4a6a'

line() {
    local mp="$1"
    df -h "$mp" &>/dev/null || return
    read -r _ total used free pct _ < <(df -h "$mp" | tail -1)
    printf '<span color="%s">%-8s</span>  <span color="%s">%6s</span>  <span color="%s">%6s</span>  <span color="%s">%6s</span>  <span color="%s">%s</span>\n' \
        "$G" "$mp" "$D" "$total" "$D" "$used" "$G" "$free" "$D" "$pct"
}

MSG="<b><span color='${G}'>󰋊  MOUNT     TOTAL    USED    FREE    USE%</span></b>"$'\n'
MSG+="<span color='${D}'>────────────────────────────────────────────</span>"$'\n'
for mp in / /home /boot; do
    row=$(line "$mp")
    [ -n "$row" ] && MSG+="${row}"$'\n'
done

cp "$dir/diskinfo.rasi" /tmp/diskinfo-test.rasi
rofi -no-config -theme /tmp/diskinfo-test.rasi -dmenu -mesg "$MSG" -p "" < /dev/null
