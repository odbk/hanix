{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  # ── Flake embebido en la ISO para instalación offline ─────────────────────
  environment.etc."hanixpkg".source = ../..; # raíz del repo → /etc/hanixpkg

  # ── Comando hanix-install disponible en el live ───────────────────────────
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "hanix-install" (builtins.readFile ../install))
  ];

  # ── Bootloader — anular config del sistema base ───────────────────────────
  # iso-image.nix gestiona su propio bootloader; desactivamos los del sistema
  boot.loader.systemd-boot.enable        = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables   = lib.mkForce false;
  # grub ya lo fuerza a false installation-cd-base.nix, pero por si acaso:
  boot.loader.grub.enable                = lib.mkForce false;

  # ── Plymouth — no aplica en live ──────────────────────────────────────────
  boot.plymouth.enable       = lib.mkForce false;
  boot.initrd.kernelModules  = lib.mkForce [ "loop" "iso9660" "overlay" "squashfs" ];

  # ── Usuario live: hanix / hanix ───────────────────────────────────────────
  hanix.mainUser = lib.mkForce "hanix";

  users.users.hanix = {
    initialPassword = lib.mkForce "hanix";
  };

  # ── Autologin — greetd lanza i3 directamente sin pantalla de login ────────
  services.greetd.settings.initial_session = {
    command = "${pkgs.xorg.xinit}/bin/startx ${pkgs.i3}/bin/i3 -- :0 vt1";
    user    = "hanix";
  };

  # ── Imagen ISO ────────────────────────────────────────────────────────────
  isoImage.isoName          = lib.mkForce "hanix.iso";
  isoImage.makeEfiBootable  = true;
  isoImage.makeUsbBootable  = true;
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  networking.hostName = "hanix";
  networking.wireless.enable = lib.mkForce false;
}
