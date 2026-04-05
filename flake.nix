{
  description = "Configuración compartida";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = { self, nixpkgs, unstable, ... } @ inputs: 
  let
    system = "x86_64-linux";

    # Función para crear instancias de pkgs con configuración común
    mkPkgs = pkgsInput: import pkgsInput {
      inherit system;
      config.allowUnfree = true;
    };

    pkgs = mkPkgs nixpkgs;
    unstablePkgs = mkPkgs unstable;

    commonModules = [
      inputs.nixvim.nixosModules.nixvim
      ./shared/user-option.nix   # define la opción hanix.mainUser
      ./shared/default-user.nix  # crea el usuario según mainUser
      ./shared/configuration.nix
      ./shared/hacking.nix
      ./shared/essentials.nix
      ./shared/extras.nix
      ./shared/themes/appearance.nix
      ./shared/themes/nixvim.nix
      ./shared/themes/plymouth.nix
      ./shared/personal.nix      # stub — edita localmente con skip-worktree
    ];

    # Módulos para la ISO — igual que commonModules pero sin personal.nix
    isoModules = [
      inputs.nixvim.nixosModules.nixvim
      ./shared/user-option.nix
      ./shared/default-user.nix
      ./shared/configuration.nix
      ./shared/hacking.nix
      ./shared/essentials.nix
      ./shared/extras.nix
      ./shared/themes/appearance.nix
      ./shared/themes/nixvim.nix
      ./shared/themes/plymouth.nix
      ./shared/iso.nix           # autologin, usuario hanix/hanix, imagen ISO
    ];

    # Función para crear configuraciones NixOS con argumentos comunes
    mkNixosSystem = extraModules: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules ++ extraModules;
      specialArgs = {
        inherit pkgs unstablePkgs;
        inherit inputs;
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
    packages.${system}.iso = (unstable.lib.nixosSystem {
      inherit system;
      modules = isoModules;
      specialArgs = {
        inherit pkgs unstablePkgs;
        inherit inputs;
      };
    }).config.system.build.isoImage;
  };
}
