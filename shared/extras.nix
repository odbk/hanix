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
    (pkgs.tumbler or pkgs.xfce.tumbler)                             # miniaturas en Thunar
    evince                                                          # visor de PDF
    btop                                                            # monitor del sistema
    gparted                                                         # gestor de discos gráfico
    (pkgs.thunar-archive-plugin or pkgs.xfce.thunar-archive-plugin) # comprimidos en Thunar
    xarchiver                    # backend para abrir/crear zips, tars, etc.

  ];
}
