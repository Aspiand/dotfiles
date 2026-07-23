{
  description = "myvm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dotfiles.url = "path:../../";

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, dotfiles, microvm, ... }:
    let
      system = "x86_64-linux";
      mkVm = name: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          microvm.nixosModules.microvm
          dotfiles.nixosModules.base
          dotfiles.nixosModules.ssh
          ./${name}.nix
        ];
      };
    in {
      nixosConfigurations.minimal = mkVm "minimal";
      nixosConfigurations.gnome   = mkVm "gnome";

      packages.${system} = {
        minimal = self.nixosConfigurations.minimal.config.microvm.declaredRunner;
        gnome   = self.nixosConfigurations.gnome.config.microvm.declaredRunner;
      };
    };
}
