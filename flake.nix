{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      inherit (lib.fileset) toList fileFilter;

      isNixModule = file: file.hasExt "nix" && file.name != "flake.nix" && !lib.hasPrefix "_" file.name;

      importTree = path: toList (fileFilter isNixModule path);
      mkFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; };
    in
    mkFlake {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = importTree ./nix;
    };
}
