{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  nixConfig = {
    substituters = [
      "https://nix.aspian.my.id"
    ];
    trusted-public-keys = [
      "github-ci-1:qjsecsjhdp0svqh6aXFEaaYtsTh5U+Ca6Jzmk46wXOY=" # TODO: remove
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
