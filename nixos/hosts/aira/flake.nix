{
  description = "NixOS configuration for aira";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      grub2-themes,
      spicetify-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      hanabiFlakeModule = import ../../../nix/hanabi.nix { };
    in
    {
      nixosConfigurations = {
        aira = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./gnome.nix
            grub2-themes.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                (final: _: {
                  hanabi = hanabiFlakeModule.flake.lib.hanabi.mkPackage final;
                })
              ];
            }
            {
              home-manager = {
                extraSpecialArgs = { inherit inputs; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.ao = ./home.nix;
                backupFileExtension = "bak";
              };
            }
          ];
        };
      };
    };
}
