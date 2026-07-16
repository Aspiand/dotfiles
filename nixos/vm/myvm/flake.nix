{
  description = "myvm — disposable NixOS testing VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dotfiles.url = "path:../../../";

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, dotfiles, microvm }:
    let
      system = "x86_64-linux";
    in {
      packages.${system} = {
        default = self.packages.${system}.myvm;
        myvm = self.nixosConfigurations.myvm.config.microvm.declaredRunner;
      };

      nixosConfigurations.myvm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          microvm.nixosModules.microvm
          dotfiles.nixosModules.base
          dotfiles.nixosModules.ssh
          ./configuration.nix
        ];
      };
    };
}
