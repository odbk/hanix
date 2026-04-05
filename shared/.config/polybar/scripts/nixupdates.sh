#!/usr/bin/env bash
# Comprueba si hay actualizaciones en los inputs del flake.
# Usa caché de 1 hora para no abusar de la API de GitHub.

FLAKE_DIR="${FLAKE_DIR:-$HOME/hanix}"
LOCK="$FLAKE_DIR/flake.lock"
CACHE_DIR="/tmp/hanix-updates"
mkdir -p "$CACHE_DIR"

[ -f "$LOCK" ] || { echo "󰒃 ?"; exit 0; }

UPDATES=0

check_input() {
    local name="$1"
    local cache="$CACHE_DIR/$name"

    local current_rev
    current_rev=$(jq -r ".nodes.\"$name\".locked.rev // empty" "$LOCK" 2>/dev/null)
    [ -z "$current_rev" ] && return

    local owner type ref
    type=$(jq -r ".nodes.\"$name\".original.type // empty" "$LOCK" 2>/dev/null)
    [ "$type" != "github" ] && return

    owner=$(jq -r ".nodes.\"$name\".original.owner" "$LOCK" 2>/dev/null)
    repo=$(jq -r ".nodes.\"$name\".original.repo" "$LOCK" 2>/dev/null)
    ref=$(jq -r ".nodes.\"$name\".original.ref // \"HEAD\"" "$LOCK" 2>/dev/null)

    # Refrescar caché si tiene más de 1 hora
    if [ ! -f "$cache" ] || [ $(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) )) -gt 3600 ]; then
        local latest
        latest=$(curl -sf --max-time 8 \
            "https://api.github.com/repos/$owner/$repo/commits/$ref" \
            | jq -r '.sha // empty' 2>/dev/null)
        [ -n "$latest" ] && echo "$latest" > "$cache"
    fi

    [ -f "$cache" ] || return
    local latest_rev
    latest_rev=$(cat "$cache")

    [ "$current_rev" != "$latest_rev" ] && UPDATES=$(( UPDATES + 1 ))
}

# Comprobamos los inputs principales del flake
for node in nixpkgs unstable nixvim; do
    check_input "$node"
done

if [ "$UPDATES" -gt 0 ]; then
    echo "%{F#ffcc00}󰚰 $UPDATES%{F-} %{F#1a6b1a}⟫%{F-}"
fi
