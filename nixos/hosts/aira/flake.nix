{
  description = "NixOS configuration for aira";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dotfiles.url = "path:../../../";
    home-config.url = "path:../../../home-manager";

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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      grub2-themes,
      spicetify-nix,
      sops-nix,
      dotfiles,
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
            ./hardware-configuration.nix
            ./gnome.nix
            grub2-themes.nixosModules.default
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            dotfiles.modules
            dotfiles.nixosModules.base
            dotfiles.nixosModules.desktop
            dotfiles.nixosModules.ssh
            dotfiles.nixosModules.node-exporter
            {
              system.nixos.revision = nixpkgs.lib.mkDefault (self.rev or self.dirtyRev or "Unknown");
              nixpkgs.overlays = [ inputs.dotfiles.overlays.default ];
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
