{ pkgs, unstablePkgs, ... }:

{

  services.gvfs.enable         = true;
  services.udisks2.enable      = true;
  services.spice-vdagentd.enable = true;
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
    openssl
    jq
    dig
    tmux

    # ── Diagnóstico de hardware y red ─────────────────────
    usbutils      # lsusb
    pciutils      # lspci
    lshw          # info completa de hardware
    iw            # gestión de interfaces WiFi
    ethtool       # info y config de tarjeta de red
    mtr           # traceroute + ping combinado
    whois         # consulta de dominios
    acpi          # batería, temperatura y AC desde CLI
    (pkgs.thunar or pkgs.xfce.thunar)
    (pkgs.thunar-volman or pkgs.xfce.thunar-volman)  # montaje automático de USBs
    gvfs
    samba                        # backend SMB para gvfs/Thunar
    alacritty
    foot
    firefox
    openvpn
    sshpass
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
    pavucontrol                     # mixer gráfico (click en icono de volumen)
    pasystray                       # applet de volumen en la bandeja del sistema
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
    python3
    python2
    python3Packages.requests
    python3Packages.beautifulsoup4
    python3Packages.paramiko
    python3Packages.pycryptodome
    python3Packages.pyopenssl
    python3Packages.colorama
    python3Packages.termcolor
    ruby
    jdk
  ]) ++
  (with unstablePkgs; [
    claude-code
  ]);
}
