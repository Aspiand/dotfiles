{
  description = "NixOS configuration for nova";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    dotfiles.url = "path:../../../";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      sops-nix,
      dotfiles,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nova = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.default
          sops-nix.nixosModules.sops
          ./hardware.nix
          ./disko.nix
          ./configuration.nix
          dotfiles.nixosModules.base
          dotfiles.nixosModules.ssh
          # dotfiles.nixosModules.victoriametrics
          # dotfiles.nixosModules.node-exporter
        ];
      };
    };
}
