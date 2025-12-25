{
  description = "NixOS configuration";

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

    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      grub2-themes,
      copyparty,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        aira = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            grub2-themes.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                copyparty.overlays.default
                (final: prev: {
                  hanabi = (import ./hanabi.nix {
                    pkgs = final;
                    stdenv = final.stdenv;
                    fetchFromGitHub = final.fetchFromGitHub;
                  }).hanabi;
                })
              ];
            }
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.ao = ./home.nix;
                backupFileExtension = "bak";
              };
            }
          ];
        };
      };

      # homeConfigurations = {
      #   backupFileExtension = "bak";
      #   ao = home-manager.lib.homeManagerConfiguration {
      #     pkgs = import nixpkgs { inherit system; };
      #     modules = [ ./home.nix ];
      #   };
      # };
    };
}
