{ pkgs, lib, config, ... }:

let
  hanixTheme = pkgs.stdenvNoCC.mkDerivation {
    name = "plymouth-theme-hanix";
    src  = ./plymouth/hanix;

    dontBuild   = true;
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/hanix
      cp hanix.plymouth hanix.script logo.png $out/share/plymouth/themes/hanix/
      # Fix ImageDir path to match installed location
      sed -i "s|ImageDir=.*|ImageDir=$out/share/plymouth/themes/hanix|" \
        $out/share/plymouth/themes/hanix/hanix.plymouth
      sed -i "s|ScriptFile=.*|ScriptFile=$out/share/plymouth/themes/hanix/hanix.script|" \
        $out/share/plymouth/themes/hanix/hanix.plymouth
    '';
  };
in
{
  boot.plymouth = {
    enable = true;
    theme  = "hanix";
    themePackages = [ hanixTheme ];
  };

  # KMS: carga los módulos GPU configurados en hanix.plymouthGpuModules
  boot.initrd.kernelModules = config.hanix.plymouthGpuModules;

  # Reducir generaciones para no llenar /boot
  boot.loader.systemd-boot.configurationLimit = lib.mkForce 2;
}
