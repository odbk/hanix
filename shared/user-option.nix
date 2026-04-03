{ lib, ... }: {
  options.hanix.mainUser = lib.mkOption {
    type        = lib.types.str;
    default     = "hanix";
    description = "Nombre del usuario principal del sistema.";
  };
}
