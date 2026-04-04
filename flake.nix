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
      ./shared/nixvim.nix
      ./shared/plymouth.nix      # boot splash HaNiX
      ./shared/personal.nix      # stub — edita localmente con skip-worktree
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
      # nixos-rebuild switch --flake . (sin tag, usa el hostname actual)
      hanixcel = mkNixosSystem [
        ./hardware-configuration.nix
        ./shared/appearance.nix
        { networking.hostName = "hanixcel"; }
      ];

      # Alias para instalaciones frescas (hostname por defecto de NixOS)
      nixos = mkNixosSystem [
        ./hardware-configuration.nix
        ./shared/appearance.nix
        { networking.hostName = "hanixcel"; }
      ];

      hanix-vm = mkNixosSystem [
        ./hardware-configuration.nix
        ./shared/vmware.nix
        ./shared/appearance.nix
        { networking.hostName = "hanix-vm"; }
      ];
    };
  };
}
