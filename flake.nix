{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    wrappers.url = "github:Lassulus/wrappers";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
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
      flakeLib = import ./lib { inherit lib; };
      mkFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; };

      mergedCustomModules = flakeLib.loadCustomModules ./nix/modules;

      flakeOutputs = mkFlake {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = (flakeLib.importTree ./nix/packages) ++ (flakeLib.importTree ./nixos/modules) ++ (flakeLib.importTree ./nix/wrappers);

        perSystem = { pkgs, lib, ... }: {
          formatter = pkgs.nixpkgs-fmt;

          checks.lib-tests = flakeLib.runTests {
            inherit pkgs;
            mylib = import ./lib { inherit lib; };
          };
        };
      };
    in
    flakeOutputs
    // {
      nixosModules = (flakeOutputs.nixosModules or { }) // {
        default = { ... }: { };
      };

      customModules = mergedCustomModules;
      modules.imports = builtins.attrValues mergedCustomModules;

      overlays = flakeOutputs.overlays // {
        default = flakeLib.mkDefaultOverlay {
          overlays = flakeOutputs.overlays;
          libExt = super: { my = import ./lib { lib = super; }; };
        };
      };
    };
}
