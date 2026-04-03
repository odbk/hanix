{ config, pkgs, ... }:

{
  ##############################
  ## INTEGRACIÓN CON VMWARE ##
  ##############################

  # Paquete con las herramientas necesarias
  environment.systemPackages = with pkgs; [
    open-vm-tools
  ];

  # Servicio principal
  virtualisation.vmware.guest.enable = true;
  services.xserver.videoDrivers = [ "vmware" ];

  # Archivo para autoiniciar vmware-user en sesiones X11
  # Solo necesario si no usas un DE como GNOME/KDE
  systemd.user.services.vmware-user = {
    enable = true;
    description = "VMware user integration";
    after = [ "graphical-session.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.open-vm-tools}/bin/vmware-user-suid-wrapper";
    };
  };

  # OPCIONAL: si quieres asegurarte de que el entorno está en UEFI para evitar problemas con resolución
  assertions = [
    {
      assertion = config.boot.loader.systemd-boot.enable -> config.boot.loader.efi.canTouchEfiVariables;
      message = "Si usas systemd-boot, debes habilitar canTouchEfiVariables para que funcione con UEFI correctamente.";
    }
  ];
}
