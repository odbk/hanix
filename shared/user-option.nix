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
    default     = "/dev/sda";
    description = "Disco donde instalar GRUB en sistemas BIOS (ignorado en UEFI).";
  };

  options.hanix.plymouthGpuModules = lib.mkOption {
    type        = lib.types.listOf lib.types.str;
    default     = [];
    description = "Módulos KMS a cargar en el initrd para Plymouth. Pon el de tu GPU: amdgpu, i915, nouveau, radeon.";
  };
}
