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
      ./shared/personal.nix      # stub — edita localmente con skip-worktree
    ];

    # Función para crear configuraciones NixOS con argumentos comunes
    mkNixosSystem = hostName: extraModules: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules ++ extraModules;
      specialArgs = { 
        inherit pkgs unstablePkgs;
        inherit inputs;
      };
    };
  in {
    nixosConfigurations = {
      laptop = mkNixosSystem "laptop" [
        ./hosts/laptop.nix
        ./shared/appearance.nix
        { networking.hostName = "hanixcel"; }
      ];

      vm = mkNixosSystem "vm" [
        ./hosts/vm.nix
        ./shared/vmware.nix
        ./shared/appearance.nix
        { networking.hostName = "hanix-vm"; }
      ];

      pc = mkNixosSystem "pc" [
        ./hosts/pc.nix
        ./shared/appearance.nix
        { networking.hostName = "hanixcel"; }
      ];
    };
  };
}
