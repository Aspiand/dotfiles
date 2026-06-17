{
  description = "NixOS configuration for alibaba";

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
      nixosConfigurations.alibaba = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.default
          ./hardware.nix
          ./disko.nix
          ./configuration.nix
          ./services.nix
          dotfiles.nixosModules.base
          dotfiles.nixosModules.ssh
          dotfiles.nixosModules.fail2ban
          dotfiles.nixosModules.tailscale
        ];
      };
    };
}
