{
  description = "Multi-profile Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      flake = {
        # Individual profiles can still be accessed here, 
        # but they now point to their own directories which have their own flakes.
        # This root flake will have its own lock file, while sub-flakes have theirs.
        
        homeConfigurations = {
          manjaro = (import ./profiles/manjaro/flake.nix).outputs inputs;
          mint = (import ./profiles/mint/flake.nix).outputs inputs;
          pc = (import ./profiles/work/flake.nix).outputs inputs;
          yuki = (import ./profiles/yuki/flake.nix).outputs inputs;
        };
      };
    };
}
