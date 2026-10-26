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

      # Names exported by nix/packages only — nix/wrappers exports must not be
      # overlaid, or they would shadow nixpkgs attrs (git, tmux, fzf, ...).
      packageNames = lib.unique (
        lib.concatMap (f: builtins.attrNames ((import f { }).perSystem { pkgs = null; }).packages) (
          flakeLib.importTree ./nix/packages
        )
      );

      flakeOutputs = mkFlake {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports =
          (flakeLib.importTree ./nix/packages)
          ++ (flakeLib.importTree ./nixos/modules)
          ++ (flakeLib.importTree ./nix/wrappers);

        perSystem = { pkgs, lib, ... }: {
          formatter = pkgs.nixfmt;

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

      # Single overlay: every `nix build .#<name>` is also `pkgs.<name>` on any
      # host, built from this flake's nixpkgs so the derivation is identical.
      overlays.default =
        final: prev:
        let
          packages = flakeOutputs.packages.${prev.stdenv.hostPlatform.system} or { };
        in
        lib.genAttrs packageNames (name: packages.${name})
        // {
          lib = prev.lib.extend (_: super: { my = import ./lib { lib = super; }; });
        };
    };
}
