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

  system.nixos.distroName = "HaNiX";
  system.nixos.label      = lib.mkForce "26.04";

  # Silenciar mensajes de boot en pantalla (evita que aparezcan en el login)
  boot.kernelParams    = [ "quiet" "loglevel=3" "systemd.show_status=false" ];
  boot.consoleLogLevel = 3;
  boot.blacklistedKernelModules = [ "pcspkr" "snd_pcsp" ];


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

  services.xserver.xkb = {
    layout  = "es";
    variant = "";
  };

  # Usuario definido en personal.nix (skip-worktree, no se sube a git)

  # Allow unfree packages
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
