{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ── Audio ─────────────────────────────────────────────
    qpwgraph                        # gestor visual de enrutado PipeWire

    # ── Chats / Comunicaciones ────────────────────────────
    telegram-desktop

    # ── Pantalla ──────────────────────────────────────────
    redshift                        # filtro de luz azul con applet de bandeja

    # ── Utilidades de escritorio ──────────────────────────
    fastfetch
    vlc
    eog                          # visor de imágenes
    btop                                                            # monitor del sistema
    gparted                                                         # gestor de discos gráfico
    xarchiver                    # backend para abrir/crear zips, tars, etc.

  ];
}
