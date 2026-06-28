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

    hermes-agent.url = "github:NousResearch/hermes-agent";
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      sops-nix,
      hermes-agent,
      dotfiles,
    }:
    {
      nixosConfigurations.nova = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.default
          sops-nix.nixosModules.sops
          ./hardware.nix
          ./disko.nix
          ./configuration.nix
          dotfiles.nixosModules.base
          dotfiles.nixosModules.ssh
          # dotfiles.nixosModules.grafana
          # dotfiles.nixosModules.victoriametrics
          # dotfiles.nixosModules.victorialogs
          # dotfiles.nixosModules.node-exporter

          # dotfiles.nixosModules.searxng
          # dotfiles.nixosModules.headroom
        ];
      };
    };
}
