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
      config.permittedInsecurePackages = [ "mbedtls-2.28.10" ];
    };

    unstablePkgs = mkPkgs unstable;

    commonModules = [
      ./shared/user-option.nix   # define la opción hanix.mainUser
      ./shared/default-user.nix  # crea el usuario según mainUser
      ./shared/configuration.nix
      ./shared/behaviour.nix
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
      nixpkgs.config.permittedInsecurePackages = [ "mbedtls-2.28.10" ];
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
        flakeRoot    = ./.;  # raíz del flake evaluada aquí, no en iso.nix
        isIso        = true;
      };
    }).config.system.build.isoImage;
  };
}
