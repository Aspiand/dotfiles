{
  description = "NixOS configuration for aira";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dotfiles.url = "path:../../../";

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

    hermes-agent.url = "github:NousResearch/hermes-agent";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      grub2-themes,
      spicetify-nix,
      hermes-agent,
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
            ./hermes.nix
            grub2-themes.nixosModules.default
            hermes-agent.nixosModules.default
            home-manager.nixosModules.home-manager
            dotfiles.nixosModules.base
            dotfiles.nixosModules.desktop
            dotfiles.nixosModules.ssh
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
