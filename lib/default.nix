{ lib }:

let
  # Recursively wraps every non-attrs leaf value with lib.mkDefault
  # Attrsets are recursed into depth-first; only leaves get mkDefault.
  mkDefaults =
    attrs:
    lib.mapAttrs (
      name: value:
      if
        builtins.isAttrs value && (value.type or null) != "derivation" && !(builtins.hasAttr "_type" value)
      then
        mkDefaults value
      else
        lib.mkDefault value
    ) attrs;

  # Collect .nix files from a directory, skipping flake.nix and _prefixed files.
  # Uses lib.fileset for efficient filtering.
  importTree =
    path:
    lib.fileset.toList (
      lib.fileset.fileFilter (
        file: file.hasExt "nix" && file.name != "flake.nix" && !lib.hasPrefix "_" file.name
      ) path
    );

  # Read a directory of flake modules (nix/modules/*.nix), import each,
  # extract the `flake.customModules` attribute, and merge them all into one set.
  # This bypasses flake-parts to avoid type-checking issues with NixOS module functions.
  loadCustomModules =
    dir:
    let
      isRegular =
        n: v: v == "regular" && lib.hasSuffix ".nix" n && n != "flake.nix" && !lib.hasPrefix "_" n;
      files = lib.filterAttrs isRegular (builtins.readDir dir);
      paths = map (n: dir + "/${n}") (builtins.attrNames files);
      mods = map (f: (import f { }).flake.customModules or { }) paths;
    in
    builtins.foldl' (acc: m: acc // m) { } mods;

  # Build the default overlay: merge all per-package overlays (from flake-parts)
  # plus extend nixpkgs lib with `libExt` (usually `{ my = import ./lib ... }`).
  mkDefaultOverlay =
    { overlays, libExt }:
    final: prev:
    let
      base = lib.foldl' (acc: overlay: acc // (overlay final acc)) { } (
        lib.attrValues (lib.removeAttrs overlays [ "default" ])
      );
    in
    base
    // {
      lib = prev.lib.extend (_: super: libExt super);
    };

  # Run mylib tests (#[test]) and produce a pass/fail derivation.
  runTests =
    { pkgs, mylib }:
    let
      testResults = import ./test.nix { inherit lib mylib; };
      allPass = lib.all lib.id (lib.attrValues testResults);
      total = builtins.length (lib.attrNames testResults);
    in
    if allPass then
      pkgs.runCommand "lib-tests-passed" { } ''
        echo "All ${toString total} tests passed" > $out
      ''
    else
      let
        failed = lib.filterAttrs (_: v: !v) testResults;
      in
      pkgs.runCommand "lib-tests-failed" { } ''
        echo "FAILED: ${toString (builtins.length (lib.attrNames failed))}/${toString total} test(s)" >&2
        ${lib.concatMapStringsSep "\n" (n: "echo '  ${n}' >&2") (lib.attrNames failed)}
        exit 1
      '';
in
{
  inherit
    mkDefaults
    importTree
    loadCustomModules
    mkDefaultOverlay
    runTests
    ;
}
