{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];

  # Bootloader — auto-detecta UEFI o BIOS
  boot.loader.systemd-boot.enable          = builtins.pathExists "/sys/firmware/efi/efivars";
  boot.loader.systemd-boot.configurationLimit = 3;  # overridden to 2 in plymouth.nix when Plymouth is active
  boot.loader.efi.canTouchEfiVariables     = builtins.pathExists "/sys/firmware/efi/efivars";
  boot.loader.grub = lib.mkIf (!builtins.pathExists "/sys/firmware/efi/efivars") {
    enable = true;
    device = config.hanix.grubDevice;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Silenciar mensajes de boot en pantalla (evita que aparezcan en el login)
  boot.kernelParams    = [ "quiet" "loglevel=3" "systemd.show_status=false" ];
  boot.consoleLogLevel = 3;


  programs.bash.shellAliases = {
    rebuild     = "${config.hanix.flakePath}/rebuild";
    rebuild-dry = "${config.hanix.flakePath}/rebuild dry-run";
    update      = "(cd ${config.hanix.flakePath} && nix flake update && ./rebuild)";
    hex         = "xxd";
  };

  # Fastfetch + funciones de hacking al abrir terminal interactivo
  programs.bash.interactiveShellInit = ''
    fastfetch

    # ── Hacking utils ──────────────────────────────────────
    http()  { python3 -m http.server "''${1:-8080}"; }
    ports() { nmap -sV --open -T4 "$@"; }
    b64e()  { echo -n "''${1:-$(cat)}" | base64 -w0; echo; }
    b64d()  { echo -n "''${1:-$(cat)}" | base64 -d; echo; }
    urle()  { python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))"; }
    urld()  { python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"; }
    vpnip() { ip addr 2>/dev/null | grep -A2 'tun\|wg' | grep 'inet ' | awk '{print $2}' | cut -d/ -f1; }
    myip()  { curl -s ifconfig.me; echo; }
  '';

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

  # This value determines the NixOS release from which the default
  system.stateVersion = "24.11"; # Did you read the comment?
}
