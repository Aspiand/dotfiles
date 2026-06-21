{
  description = "NixOS configuration for alef (Amlogic S905X TV Box)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      system = "aarch64-linux";
    in
    {
      nixosConfigurations.alef = nixpkgs.lib.nixosSystem {
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
