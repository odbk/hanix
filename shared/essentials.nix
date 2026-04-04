{ pkgs, unstablePkgs, ... }:

{
  virtualisation.docker.enable = true;

  services.gvfs.enable = true;
  environment.pathsToLink = [ "/share/dbus-1" "/share/gvfs" ];

  environment.systemPackages = (with pkgs; [

    wget
    curl
    jq
    tmux
    xfce.thunar
    xfce.thunar-volman           # montaje automático de USBs
    gvfs
    samba                        # backend SMB para gvfs/Thunar
    alacritty
    foot
    firefox
    openvpn
    chromium
    google-chrome
    vscode
    git
    networkmanagerapplet
    killall
    geany
    blueman
    wireplumber
    helvum
    unzip

    ### DEVOS
    nasm
    gdb
    gcc
    binutils
    gnumake
    hexedit
  ]) ++
  (with unstablePkgs; [
    claude-code
  ]);
}
