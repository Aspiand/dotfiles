{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  nixConfig = {
    substituters = [
      "https://nix.aspian.my.id"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "github-ci-2:eUvIhhjHCO/kJVGcFNd/sNCGSx59tj1QAXmb477OO00="
    ];
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      inherit (lib.fileset) toList fileFilter;

      isNixModule = file: file.hasExt "nix" && file.name != "flake.nix" && !lib.hasPrefix "_" file.name;

      importTree = path: toList (fileFilter isNixModule path);
      mkFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; };

      flakeOutputs = mkFlake {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = importTree ./nix;
      };
    in
    flakeOutputs
    // {
      overlays = flakeOutputs.overlays // {
        default =
          final: prev:
          lib.foldl' (acc: overlay: acc // (overlay final acc)) { } (
            lib.attrValues (lib.removeAttrs flakeOutputs.overlays [ "default" ])
          );
      };
    };
}
