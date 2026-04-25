{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ── Audio ─────────────────────────────────────────────
    qpwgraph                        # gestor visual de enrutado PipeWire

    # ── Chats / Comunicaciones ────────────────────────────
    telegram-desktop
    discord
    ferdium

    # ── Escritorio remoto ─────────────────────────────────
    rustdesk

    # ── Pantalla ──────────────────────────────────────────
    redshift                        # filtro de luz azul con applet de bandeja

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
