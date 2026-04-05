{ config, pkgs, lib, ... }:

let
  # ASCII art para el login — generado como fichero en el store
  hanixArt = pkgs.writeText "hanix-art" ''

    ██╗  ██╗ █████╗ ███╗  ██╗██╗██╗  ██╗
    ██║  ██║██╔══██╗████╗ ██║██║╚██╗██╔╝
    ███████║███████║██╔██╗██║██║ ╚███╔╝
    ██╔══██║██╔══██║██║╚████║██║ ██╔██╗
    ██║  ██║██║  ██║██║ ╚███║██║██╔╝╚██╗
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚══╝╚═╝╚═╝  ╚═╝

  '';

  # Comando de greetd — script para evitar problemas de escaping
  greetCmd = pkgs.writeShellScript "greet-start" ''
    exec ${pkgs.greetd.tuigreet}/bin/tuigreet \
      --time \
      --remember \
      --remember-session \
      --xsessions "${config.services.displayManager.sessionData.desktops}/share/xsessions" \
      --xsession-wrapper "${pkgs.xorg.xinit}/bin/startx /usr/bin/env" \
      --greeting "$(cat ${hanixArt})" \
      --greet-align left \
      --theme "border=green;text=green;prompt=green;time=green;action=green;button=green;container=black;input=green" \
      --asterisks \
      --window-padding 2
  '';
in

{
  ###########################
  ## DOTFILES USUARIO      ##
  ###########################

  # Esqueleto para usuarios nuevos
  environment.etc."skel/.config".source = ../.config;
  environment.etc."skel/.Xresources".text = ''
    Xft.dpi: 96
    Xft.antialias: 1
    Xft.hinting: 1
    Xft.rgba: rgb
    Xft.lcdfilter: lcddefault
    Xcursor.theme: Bibata-Modern-Classic
    Xcursor.size: 24
  '';

  # Sincroniza dotfiles al home del usuario principal en cada nixos-rebuild switch
  system.activationScripts.userDotfiles = {
    text =
      let
        normalUsers = lib.filterAttrs (_: u: u.isNormalUser) config.users.users;
      in
      lib.concatMapStrings
        (u:
          let home = config.users.users.${u}.home; in ''
            if [ -d /etc/skel/.config ] && [ -d "${home}" ]; then
              ${pkgs.rsync}/bin/rsync -a --ignore-existing --no-perms --chmod=Du+rwx,Fu+rw --chown="${u}:users" /etc/skel/.config/ "${home}/.config/"
              find "${home}/.config" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
              find "${home}/.config" -name "checkupdates" -exec chmod +x {} \; 2>/dev/null || true
            fi
            if [ -f /etc/skel/.Xresources ] && [ -d "${home}" ]; then
              install -o "${u}" -g users /etc/skel/.Xresources "${home}/.Xresources"
            fi
            # Cursor theme — necesario para que X11 lo aplique
            mkdir -p "${home}/.icons/default"
            echo -e '[Icon Theme]\nInherits=Bibata-Modern-Classic' \
              > "${home}/.icons/default/index.theme"
          '')
        (lib.attrNames normalUsers);
    deps = [ "etc" ];
  };

  ###########################
  ## SESSION INIT          ##
  ###########################
  services.xserver.displayManager.sessionCommands = ''
    # ── Cursor theme ─────────────────────────────────────────────────────────
    [ -f "$HOME/.Xresources" ] && ${pkgs.xorg.xrdb}/bin/xrdb -merge "$HOME/.Xresources"
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr

    # ── Marcar como primary el monitor más ancho ──────────────────────────
    # Encuentra el monitor conectado con mayor resolución horizontal y lo
    # establece como primary (corrige el caso en que X elige el secundario).
    WIDEST=$(xrandr | grep ' connected' | while read -r LINE; do
      NAME=$(echo "$LINE" | awk '{print $1}')
      W=$(echo "$LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP '^\d+')
      [ -n "$W" ] && echo "$W $NAME"
    done | sort -rn | head -1 | awk '{print $2}')
    [ -n "$WIDEST" ] && xrandr --output "$WIDEST" --primary

    # ── Auto-detectar DPI del monitor principal ──────────────────────────
    # Lee las dimensiones físicas del monitor desde EDID (via xrandr) y
    # calcula el DPI real. Fallback a 96 si no se puede determinar.
    PRIMARY_LINE=$(xrandr | grep -m1 ' connected primary')
    [ -z "$PRIMARY_LINE" ] && PRIMARY_LINE=$(xrandr | grep -m1 ' connected')

    WIDTH_PX=$(echo "$PRIMARY_LINE" | grep -oP '\d+x\d+\+\d+\+\d+' | grep -oP '^\d+')
    WIDTH_MM=$(echo "$PRIMARY_LINE" | grep -oP '\d+mm' | head -1 | grep -oP '\d+')

    if [ -n "$WIDTH_PX" ] && [ -n "$WIDTH_MM" ] && [ "$WIDTH_MM" -gt 0 ]; then
      DPI=$(( WIDTH_PX * 254 / (WIDTH_MM * 10) ))
    else
      DPI=96
    fi
    # Clamp: mínimo 96 (texto legible en monitores grandes), máximo 300
    [ "$DPI" -lt 96  ] && DPI=96
    [ "$DPI" -gt 300 ] && DPI=192

    xrdb -merge - <<XEOF
    Xft.dpi: $DPI
    Xft.antialias: 1
    Xft.hinting: 1
    Xft.rgba: rgb
    Xft.lcdfilter: lcddefault
    XEOF

    # ── Wallpaper por monitor ─────────────────────────────────────────────
    # Primary (ultrawide): --maximize → imagen completa sin recortar
    # Secondary (FHD 16:9): --zoom    → rellena sin distorsión
    WALL="$HOME/.config/wallpaper.png"
    PRIMARY_OUT=$(xrandr | grep -m1 ' connected primary' | awk '{print $1}')
    SECONDARY_OUT=$(xrandr | grep ' connected' | grep -v ' primary' | awk '{print $1}' | head -1)
    if [ -n "$PRIMARY_OUT" ] && [ -n "$SECONDARY_OUT" ]; then
      ${pkgs.xwallpaper}/bin/xwallpaper \
        --output "$PRIMARY_OUT"   --maximize "$WALL" \
        --output "$SECONDARY_OUT" --zoom     "$WALL"
    else
      ${pkgs.xwallpaper}/bin/xwallpaper --zoom "$WALL"
    fi
  '';

  ############################
  ## AJUSTES DE DPI GLOBALES##
  ############################

  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE  = "24";
  };

  # polybar desactivado — se usa i3bar (integrado en i3)


  ############################
  ## PAQUETES DEL SISTEMA   ##
  ############################

  environment.systemPackages = with pkgs; [
    i3
    i3lock-color
    dunst
    kitty
    rofi
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    maim xclip             # captura de pantalla al portapapeles
    flameshot              # captura interactiva con anotaciones
    polkit_gnome           # agente polkit gráfico (necesario para gparted sin sudo)
    feh xwallpaper         # fondo de pantalla
    lxappearance           # cambiar temas GTK fácilmente
    bibata-cursors         # cursor theme moderno
    papirus-icon-theme     # iconos dark coherentes
    (catppuccin-gtk.override {
      accents = [ "green" ];
      size    = "standard";
      variant = "mocha";
    })
    pavucontrol
    xterm
    arandr
    (polybar.override { i3Support = true; pulseSupport = true; })
    picom
    xorg.xdpyinfo
    xorg.xinit             # startx — necesario para greetd + X11
    networkmanagerapplet   # nm-applet (bandeja sistema) + nm-connection-editor
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "*";

  ############################
  ## FUENTES                ##
  ############################
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      dejavu_fonts
      material-design-icons
      (nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Iosevka Nerd Font" "DejaVu Sans Mono" ];
        sansSerif = [ "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
      };
    };
  };

  ############################
  ## HABILITAR X11 + I3     ##
  ############################
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    windowManager.i3.enable = true;
    displayManager.lightdm.enable = false;
    desktopManager.xterm.enable = true;
  };

  # ── greetd + tuigreet — login TUI hacker con ASCII art ─────
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${greetCmd}";
      user    = "greeter";
    };
  };

  # Entradas (ratón/teclado táctil, etc.)
  services.libinput.enable = true;

}
