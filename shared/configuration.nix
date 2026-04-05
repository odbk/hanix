{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];

  # Bootloader — auto-detecta UEFI o BIOS
  boot.loader.systemd-boot.enable             = lib.mkDefault (builtins.pathExists "/sys/firmware/efi/efivars");
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables        = lib.mkDefault (builtins.pathExists "/sys/firmware/efi/efivars");
  boot.loader.grub = lib.mkIf (!builtins.pathExists "/sys/firmware/efi/efivars") {
    enable = true;
    device = config.hanix.grubDevice;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Silenciar mensajes de boot en pantalla (evita que aparezcan en el login)
  boot.kernelParams    = [ "quiet" "loglevel=3" "systemd.show_status=false" ];
  boot.consoleLogLevel = 3;


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

  services.pipewire = {
    enable       = true;
    audio.enable = true;
    pulse.enable = true;   # compatibilidad PulseAudio (pavucontrol, i3status-rust, pactl)
    alsa.enable  = true;   # compatibilidad ALSA
  };
  
  # networking.hostName — definido en cada hosts/*.nix del flake
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_ES.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "es";

  # Usuario definido en personal.nix (skip-worktree, no se sube a git)

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  # ── Bluetooth ──────────────────────────────────────────────
  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ── Wordlists — descomprimir rockyou al primer rebuild ────────
  system.activationScripts.wordlists = {
    text = ''
      ROCKYOU_GZ="${pkgs.rockyou}/share/wordlists/rockyou.txt.gz"
      DEST="/usr/share/wordlists/rockyou.txt"
      if [ -f "$ROCKYOU_GZ" ] && [ ! -f "$DEST" ]; then
        mkdir -p /usr/share/wordlists
        ${pkgs.gzip}/bin/gunzip -c "$ROCKYOU_GZ" > "$DEST"
        chmod 644 "$DEST"
      fi
    '';
  };

  # This value determines the NixOS release from which the default
  system.stateVersion = "24.11"; # Did you read the comment?
}
