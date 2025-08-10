{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in {
    homeConfigurations = {
      "manjaro" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./profiles/manjaro.nix ];
      };

      "mint" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./profiles/mint.nix ];
      };

      "pc" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./profiles/work.nix ];
      };

      "yuki" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./profiles/yuki.nix ];
      };
    };
  };
}