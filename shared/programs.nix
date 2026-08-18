{ pkgs, ... }:

{
  # Usa los módulos NixOS como interfaz declarativa cuando están pensados para
  # instalar/configurar el programa. Varios añaden además D-Bus/systemd,
  # permisos, plugins, variables de entorno o configuración.
  programs = {
    adb.enable = true;

    dconf.enable = true;

    evince.enable = true;
    firefox.enable = true;

    fzf = {
      keybindings     = true;
      fuzzyCompletion = true;
    };

    ghidra.enable = true;

    git = {
      enable = true;
      config.init.defaultBranch = "main";
    };

    i3lock = {
      enable  = true;
      package = pkgs.i3lock-color;
    };

    java.enable = true;

    # Estos módulos crean wrappers con capacidades limitadas. Los grupos
    # correspondientes se asignan al usuario principal en default-user.nix.
    mtr.enable     = true;
    tcpdump.enable = true;

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    tmux = {
      enable       = true;
      baseIndex    = 1;
      clock24      = true;
      escapeTime   = 0;
      historyLimit = 50000;
      shortcut     = "a";
      terminal     = "tmux-256color";
    };

    vscode.enable = true;

    wireshark = {
      enable  = true;
      package = pkgs.wireshark;
    };
  };

  # Registra el servicio D-Bus de miniaturas utilizado por Thunar.
  services.tumbler.enable = true;
}
