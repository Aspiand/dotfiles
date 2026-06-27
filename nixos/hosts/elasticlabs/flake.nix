{
  description = "NixOS configuration for ElasticLabs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    dotfiles.url = "path:../../../";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      dotfiles,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.elasticlabs = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.default
          ./hardware.nix
          ./disko.nix
          ./configuration.nix
          dotfiles.nixosModules.base
          dotfiles.nixosModules.ssh
        ];
      };
    };
}
