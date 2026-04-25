{ config, pkgs, ... }:

{
  # ── Zsh — shell principal ─────────────────────────────────
  programs.zsh = {
    enable = true;

    autosuggestions = {
      enable = true;
      # Color dim verde para las sugerencias inline
      extraConfig.ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#1a6b1a";
    };

    syntaxHighlighting.enable = true;   # comandos válidos verde, inválidos rojo

    histSize = 50000;

    shellAliases = {
      rebuild     = "${config.hanix.flakePath}/rebuild";
      rebuild-dry = "${config.hanix.flakePath}/rebuild dry-run";
      update      = "(cd ${config.hanix.flakePath} && nix flake update && ./rebuild)";
      hex         = "xxd";
    };

    promptInit = "PROMPT='%F{#00ff41}%n@%m%f%F{#1a6b1a}:%~%f %F{#00ff41}>%f '";

    interactiveShellInit = ''
      fastfetch

      # ── Historial ────────────────────────────────────────
      HISTFILE="$HOME/.zsh_history"
      HISTDUP=erase
      setopt appendhistory sharehistory hist_ignore_space
      setopt hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

      # ── fzf — búsqueda fuzzy con tema matrix ─────────────
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
      export FZF_DEFAULT_OPTS="
        --color=fg:#cdd6f4,bg:#1e1e2e,hl:#00ff41
        --color=fg+:#00ff41,bg+:#313244,hl+:#00ff41
        --color=info:#f9e2af,prompt:#00ff41,pointer:#00ff41
        --color=marker:#00ff41,spinner:#00ff41,header:#585b70
        --border=sharp --prompt='❯ ' --pointer='▶' --marker='✓'
      "

      # ── Hacking utils ─────────────────────────────────────
      http()  { python3 -m http.server "''${1:-8080}"; }
      ports() { nmap -sV --open -T4 "$@"; }
      b64e()  { echo -n "''${1:-$(cat)}" | base64 -w0; echo; }
      b64d()  { echo -n "''${1:-$(cat)}" | base64 -d; echo; }
      urle()  { python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))"; }
      urld()  { python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"; }
      vpnip() { ip addr 2>/dev/null | grep -A2 'tun\|wg' | grep 'inet ' | awk '{print $2}' | cut -d/ -f1; }
      myip()  { curl -s ifconfig.me; echo; }
    '';
  };
}
