{ config, pkgs, lib, isIso ? false, ... }:

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

  # Evita que las máquinas instaladas acumulen indefinidamente generaciones y
  # rutas huérfanas. Se conservan 30 días de historial para poder hacer rollback.
  # En la ISO live no aporta nada: su store es de solo lectura y desaparece al
  # apagar, por eso no se programan timers allí.
  nix.gc = {
    automatic = lib.mkDefault (!isIso);
    dates = "weekly";
    options = "--delete-older-than 30d";
    randomizedDelaySec = "45min";
  };
  nix.optimise = {
    automatic = lib.mkDefault (!isIso);
    dates = [ "weekly" ];
  };

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
    wireplumber.extraConfig."51-bt-fallback" = {
      # Al desconectar BT, los streams vuelven al sink por defecto (altavoz)
      # en vez de quedarse "huérfanos" sin sonido
      "wireplumber.settings"."restore-stream.restore-target" = false;
    };
  };
  
  # networking.hostName — definido en cada hosts/*.nix del flake
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # ── SSH ────────────────────────────────────────────────────
  # openFirewall (por defecto true) abre el puerto 22.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;   # login por contraseña (LAN). Pon false si usas solo claves.
      PermitRootLogin = "no";          # nunca root directo por SSH
    };
  };

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

  # ── Impresión: CUPS + descubrimiento de red por mDNS (Avahi) ──
  services.printing.enable = true;
  services.avahi = {
    enable       = true;
    nssmdns4     = true;   # resolución mDNS (.local) de impresoras de red
    openFirewall = true;   # abre UDP 5353 (mDNS)
  };

  environment.etc."hosts".mode = "0644";

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # This value determines the NixOS release from which the default
  system.stateVersion = "24.11"; # Did you read the comment?
}
