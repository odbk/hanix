{
  description = "Configuración compartida";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, unstable, ... } @ inputs:
  let
    system = "x86_64-linux";

    # Función para crear instancias de pkgs con configuración común
    mkPkgs = pkgsInput: import pkgsInput {
      inherit system;
      config.allowUnfree = true;
      config.android_sdk.accept_license = true;
      config.permittedInsecurePackages = [ "mbedtls-2.28.10" "python-2.7.18.12" "docker-28.5.2" ];
    };

    unstablePkgs = mkPkgs unstable;

    commonModules = [
      ./shared/user-option.nix   # define la opción hanix.mainUser
      ./shared/default-user.nix  # crea el usuario según mainUser
      ./shared/configuration.nix
      ./shared/behaviour.nix
      ./shared/programs.nix
      ./shared/ianix.nix
      ./shared/hacking.nix
      ./shared/essentials.nix
      ./shared/extras.nix
      ./shared/themes/appearance.nix
      ./shared/themes/plymouth.nix
      ./shared/personal.nix      # stub — edita localmente con skip-worktree
    ];

    # Módulos para la ISO — igual que commonModules pero sin personal.nix
    isoModules = [
      ./shared/user-option.nix
      ./shared/default-user.nix
      ./shared/configuration.nix
      ./shared/behaviour.nix
      ./shared/programs.nix
      ./shared/ianix.nix
      ./shared/hacking.nix
      ./shared/essentials.nix
      ./shared/extras.nix
      ./shared/themes/appearance.nix
      ./shared/themes/plymouth.nix
      ./shared/iso.nix           # autologin, usuario hanix/hanix, imagen ISO
    ];

    # Módulo con config de nixpkgs (allowUnfree, etc.)
    nixpkgsModule = {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.android_sdk.accept_license = true;
      nixpkgs.config.permittedInsecurePackages = [ "mbedtls-2.28.10" "python-2.7.18.12" "docker-28.5.2" ];
      nixpkgs.overlays = [
        (self: super: {
          # Certipy 5.0.3 declara restricciones ~= demasiado estrechas para
          # Requests/BeautifulSoup respecto a las versiones del propio
          # nixos-25.11. Se relajan esas dos cotas y se conservan el resto de
          # comprobaciones de dependencias e importación del paquete.
          certipy = super.certipy.overridePythonAttrs (old: {
            pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [
              "requests"
              "beautifulsoup4"
            ];
          });

          hostapd = super.hostapd.overrideAttrs (old: {
            extraConfig = old.extraConfig + "\nCONFIG_WEP=y\n";
            postPatch = (old.postPatch or "") + ''
              awk '
/\tstype = WLAN_FC_GET_STYPE\(fc\);/ {
  print
  print "\twpa_printf(MSG_INFO, \"HANIX_LOG mgmt stype=%d from \" MACSTR, stype, MAC2STR(mgmt->sa));"
  next
}
/\tif \(len < IEEE80211_HDRLEN \+ sizeof\(mgmt->u\.auth\)\) \{/ {
  print "\twpa_printf(MSG_INFO, \"HANIX_LOG handle_auth from \" MACSTR, MAC2STR(mgmt->sa));"
}
/\tstatus_code = le_to_host16\(mgmt->u\.auth\.status_code\);/ {
  print
  print "\twpa_printf(MSG_INFO, \"HANIX_LOG auth_frame: alg=%d(0=Open,1=SharedKey) trans=%d status=%d from \" MACSTR,"
  print "\t\t   auth_alg, auth_transaction, status_code, MAC2STR(mgmt->sa));"
  next
}
/\tint reply_res = WLAN_STATUS_UNSPECIFIED_FAILURE;/ {
  print
  print "\twpa_printf(MSG_INFO, \"HANIX_LOG send_auth_reply: alg=%d trans=%d resp=%d to \" MACSTR, auth_alg, auth_transaction, resp, MAC2STR(dst));"
  next
}
/\tif \(!iswep \|\| !sta->challenge \|\| !challenge \|\|/ {
  print "\twpa_printf(MSG_INFO, \"HANIX_LOG wep_challenge_check: iswep=%d has_stored=%d has_received=%d\", iswep, sta->challenge != NULL, challenge != NULL);"
  print "\tif (challenge) wpa_hexdump(MSG_INFO, \"HANIX_LOG client_response(RC4_decrypted)\", challenge, WLAN_AUTH_CHALLENGE_LEN);"
  print "\tif (sta->challenge) wpa_hexdump(MSG_INFO, \"HANIX_LOG stored_challenge\", sta->challenge, WLAN_AUTH_CHALLENGE_LEN);"
}
/\tint resp = WLAN_STATUS_SUCCESS;/ {
  print
  print "\twpa_printf(MSG_INFO, \"HANIX_LOG handle_assoc from \" MACSTR, MAC2STR(mgmt->sa));"
  next
}
/\t\treply_res = send_assoc_resp\(hapd,$/ {
  print "\twpa_printf(MSG_INFO, \"HANIX_LOG send_assoc_resp status=%d to \" MACSTR, resp, MAC2STR(mgmt->sa));"
}
{ print }
' src/ap/ieee802_11.c > src/ap/ieee802_11.c.tmp && mv src/ap/ieee802_11.c.tmp src/ap/ieee802_11.c
            '';
          });
        })
      ];
    };

    # Función para crear configuraciones NixOS con argumentos comunes
    mkNixosSystem = extraModules: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules ++ extraModules ++ [ nixpkgsModule ];
      specialArgs = {
        inherit unstablePkgs inputs;
        isIso = false;
      };
    };
  in {
    nixosConfigurations = {
      hanix = mkNixosSystem [
        ./hardware-configuration.nix
        { networking.hostName = "hanix"; }
      ];

      hanixcel = mkNixosSystem [
        ./hardware-configuration.nix
        { networking.hostName = "hanixcel"; }
      ];

      # Alias para instalaciones frescas — hostname sobreescrito por personal.nix
      nixos = mkNixosSystem [
        ./hardware-configuration.nix
        ({ lib, ... }: { networking.hostName = lib.mkDefault "hanix"; })
      ];

      hanix-vm = mkNixosSystem [
        ./hardware-configuration.nix
        ./shared/vmware.nix
        { networking.hostName = "hanix-vm"; }
      ];
    };

    # ISO live — nix build .#iso
    packages.${system}.iso = (nixpkgs.lib.nixosSystem {
      inherit system;
      modules = isoModules ++ [ nixpkgsModule ];
      specialArgs = {
        inherit unstablePkgs inputs;
        # Referencia con contexto al origen ya importado del flake. Usar `./.`
        # aquí haría que Nix intentase copiar de nuevo la ruta temporal de
        # `path:.` al interpolarla en la derivación de la ISO.
        flakeRoot    = self.outPath;
        isIso        = true;
      };
    }).config.system.build.isoImage;
  };
}
