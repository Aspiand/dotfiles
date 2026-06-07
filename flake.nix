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

      # Collected directly (not through flake-parts) to avoid type-checking
      # issues with NixOS module functions.
      customModuleDir = ./nix/modules;
      customModuleFiles = lib.filterAttrs (n: v:
        v == "regular" && lib.hasSuffix ".nix" n && n != "flake.nix" && !lib.hasPrefix "_" n
      ) (builtins.readDir customModuleDir);
      customModulePaths = map (n: customModuleDir + "/${n}") (builtins.attrNames customModuleFiles);
      customModuleDefs = map (f: (import f { }).flake.customModules or { }) customModulePaths;
      mergedCustomModules = builtins.foldl' (acc: m: acc // m) { } customModuleDefs;

      flakeOutputs = mkFlake {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = (importTree ./nix/packages) ++ (importTree ./nixos/modules);

        perSystem =
          { pkgs, lib, ... }:
          let
            mylib = import ./lib { inherit lib; };
            testResults = import ./lib/test.nix { inherit lib mylib; };
            allPass = lib.all lib.id (lib.attrValues testResults);
            total = builtins.length (lib.attrNames testResults);
          in
          {
            formatter = pkgs.nixpkgs-fmt;

            checks.lib-tests =
              if allPass then
                pkgs.runCommand "lib-tests-passed" { } ''
                  echo "All ${toString total} tests passed" > $out
                ''
              else
                let
                  failed = lib.filterAttrs (_: v: !v) testResults;
                in
                pkgs.runCommand "lib-tests-failed" { }
                  ''
                    echo "FAILED: ${toString (builtins.length (lib.attrNames failed))}/${toString total} test(s)" >&2
                    ${lib.concatMapStringsSep "\n" (n: "echo '  ${n}' >&2") (lib.attrNames failed)}
                    exit 1
                  '';
          };
      };
    in
    flakeOutputs
    // {
      nixosModules =
        (flakeOutputs.nixosModules or { })
        // {
          default = { ... }: { };
        };

      customModules = mergedCustomModules;

      modules = {
        imports = builtins.attrValues mergedCustomModules;
      };

      overlays = flakeOutputs.overlays // {
        default =
          final: prev:
          let
            base = lib.foldl' (acc: overlay: acc // (overlay final acc)) { } (
              lib.attrValues (lib.removeAttrs flakeOutputs.overlays [ "default" ])
            );
          in
          base
          // {
            lib = prev.lib.extend (
              _: super: {
                my = import ./lib { lib = super; };
              }
            );
          };
      };
    };
}
