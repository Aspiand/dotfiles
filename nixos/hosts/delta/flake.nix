{
  description = "NixOS configuration for delta VM (Oracle ARM)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, disko, flake-utils }:
    let
      system = "aarch64-linux";
    in
    {
      nixosConfigurations.delta = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.default
          ./configuration.nix
        ];
      };
    };
}
