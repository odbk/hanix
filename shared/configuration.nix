{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];

  # Bootloader — auto-detecta UEFI o BIOS
  boot.loader.systemd-boot.enable          = builtins.pathExists "/sys/firmware/efi/efivars";
  boot.loader.systemd-boot.configurationLimit = 3;
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
    rebuild     = "sudo nixos-rebuild switch --impure --flake ${config.hanix.flakePath}";
    rebuild-dry = "sudo nixos-rebuild dry-run --impure --flake ${config.hanix.flakePath}";
  };

  # Fastfetch al abrir terminal interactivo
  programs.bash.interactiveShellInit = ''
    fastfetch
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
