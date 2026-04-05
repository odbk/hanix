{ pkgs, unstablePkgs, ... }:

{
  virtualisation.docker.enable = true;

  services.gvfs.enable    = true;
  services.udisks2.enable = true;
  environment.pathsToLink = [ "/share/dbus-1" "/share/gvfs" ];

  # Aplicaciones por defecto
  xdg.mime.defaultApplications = {
    "inode/directory"          = "thunar.desktop";
    "text/html"                = "google-chrome.desktop";
    "x-scheme-handler/http"    = "google-chrome.desktop";
    "x-scheme-handler/https"   = "google-chrome.desktop";
    "x-scheme-handler/about"   = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";
    "image/png"                = "eog.desktop";
    "image/jpeg"               = "eog.desktop";
    "image/gif"                = "eog.desktop";
    "image/webp"               = "eog.desktop";
    "image/svg+xml"            = "eog.desktop";
    "application/pdf"          = "evince.desktop";
    "text/plain"               = "geany.desktop";
    "video/mp4"                = "vlc.desktop";
    "video/x-matroska"         = "vlc.desktop";
    "video/webm"               = "vlc.desktop";
    "audio/mpeg"               = "vlc.desktop";
    "audio/ogg"                = "vlc.desktop";
  };

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
    udiskie                        # automontaje USBs con notificación
    libnotify                      # notify-send para scripts
    dislocker                      # montar particiones BitLocker de Windows
    brightnessctl                  # control de brillo (teclas Fn portátil)
    fzf                            # búsqueda fuzzy (Ctrl+R historial, Ctrl+T archivos)

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
