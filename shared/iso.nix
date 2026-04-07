{ config, pkgs, lib, modulesPath, flakeRoot, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  # ── Flake embebido en la ISO para instalación offline ─────────────────────
  environment.etc."hanix".source = flakeRoot; # raíz del repo → /etc/hanix

  # ── Comando hanix-install disponible en el live ───────────────────────────
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "hanix-install" (builtins.readFile "${flakeRoot}/install"))
  ];

  # ── Bootloader — anular config del sistema base ───────────────────────────
  # iso-image.nix gestiona su propio bootloader; desactivamos los del sistema
  boot.loader.systemd-boot.enable        = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables   = lib.mkForce false;
  # grub ya lo fuerza a false installation-cd-base.nix, pero por si acaso:
  boot.loader.grub.enable                = lib.mkForce false;

  # ── Plymouth — no aplica en live ──────────────────────────────────────────
  boot.plymouth.enable       = lib.mkForce false;
  boot.initrd.kernelModules  = [ "loop" "iso9660" "overlay" "squashfs" ];

  # ── Usuario live: hanix / hanix ───────────────────────────────────────────
  hanix.mainUser = lib.mkForce "hanix";

  users.users.hanix = {
    initialPassword = lib.mkForce "hanix";
  };

  # ── Autologin — greetd lanza i3 directamente sin pantalla de login ────────
  services.greetd.settings.initial_session = {
    command = "${(pkgs.xinit or pkgs.xorg.xinit)}/bin/startx ${pkgs.i3}/bin/i3 -- :0 vt1";
    user    = "hanix";
  };

  # ── Imagen ISO ────────────────────────────────────────────────────────────
  image.baseName            = lib.mkForce "hanix";
  isoImage.makeEfiBootable  = true;
  isoImage.makeUsbBootable  = true;
  # Para release final usar: "xz -Xdict-size 100%"
  isoImage.squashfsCompression = lib.mkForce "zstd -Xcompression-level 19";

  networking.hostName = "hanix";
  system.nixos.distroName = lib.mkForce "HaNiX";
  networking.wireless.enable = lib.mkForce false;
}
