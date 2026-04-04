{ lib, config, ... }: {
  options.hanix.mainUser = lib.mkOption {
    type        = lib.types.str;
    default     = "hanix";
    description = "Nombre del usuario principal del sistema.";
  };

  options.hanix.flakePath = lib.mkOption {
    type        = lib.types.str;
    default     = "/home/${config.hanix.mainUser}/hanixpkg";
    description = "Ruta al directorio del flake. Cambia en personal.nix si lo clonaste en otro sitio.";
  };

  options.hanix.grubDevice = lib.mkOption {
    type        = lib.types.str;
    default     = "/dev/sda";
    description = "Disco donde instalar GRUB en sistemas BIOS (ignorado en UEFI).";
  };
}
