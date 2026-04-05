{ lib, config, ... }: {
  options.hanix.mainUser = lib.mkOption {
    type        = lib.types.str;
    default     = "hanix";
    description = "Nombre del usuario principal del sistema.";
  };

  options.hanix.flakePath = lib.mkOption {
    type        = lib.types.str;
    default     = "/home/${config.hanix.mainUser}/hanix";
    description = "Ruta al directorio del flake. Cambia en personal.nix si lo clonaste en otro sitio.";
  };

  options.hanix.grubDevice = lib.mkOption {
    type        = lib.types.str;
    default     =
      let
        root = config.fileSystems."/".device or "/dev/sda";
        # /dev/sda1 → /dev/sda  |  /dev/nvme0n1p1 → /dev/nvme0n1
        m = builtins.match "(/dev/(nvme[0-9]+n[0-9]+|[a-z]+)).*" root;
      in if m != null then builtins.head m else "/dev/sda";
    description = "Disco donde instalar GRUB en sistemas BIOS (ignorado en UEFI). Se autodetecta desde la partición raíz.";
  };

  options.hanix.plymouthGpuModules = lib.mkOption {
    type        = lib.types.listOf lib.types.str;
    default     = [ "amdgpu" "radeon" "i915" "nouveau" "virtio_gpu" ];
    description = "Módulos KMS a cargar en el initrd para Plymouth. Por defecto incluye los más comunes.";
  };
}
