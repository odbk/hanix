{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ── Chats / Comunicaciones ────────────────────────────
    telegram-desktop
    discord
    ferdium

    # ── Utilidades de escritorio ──────────────────────────
    fastfetch
    vlc
    eog                          # visor de imágenes
    xfce.tumbler                 # miniaturas en Thunar (imágenes, vídeos, PDFs)
    evince                       # visor de PDF
    btop                         # monitor del sistema
    gparted                      # gestor de discos gráfico
    xfce.thunar-archive-plugin   # integración de comprimidos en Thunar
    xarchiver                    # backend para abrir/crear zips, tars, etc.

  ];
}
