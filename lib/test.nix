{
  lib,
  mylib,
}:
let
  inherit (lib) mapAttrs filterAttrs;
  mkFn = mylib.mkDefaults;

  tests = {
    testFlatAttrs = mkFn { a = 1; b = "hello"; c = true; }
      == { a = lib.mkDefault 1; b = lib.mkDefault "hello"; c = lib.mkDefault true; };

    testNestedOneLevel = mkFn { services.openssh = { enable = true; ports = [ 22 ]; }; }
      == { services.openssh = { enable = lib.mkDefault true; ports = lib.mkDefault [ 22 ]; }; };

    testDeepNested = mkFn { a.b.c = 42; }
      == { a.b.c = lib.mkDefault 42; };

    testMixedLeavesAndSubAttrs = mkFn { a.b = 1; a.c = 2; d = 3; }
      == { a = { b = lib.mkDefault 1; c = lib.mkDefault 2; }; d = lib.mkDefault 3; };

    testEmptyAttrs = mkFn { } == { };

    testListLeaf = mkFn { a = [ 1 2 3 ]; }
      == { a = lib.mkDefault [ 1 2 3 ]; };

    testStringWithSpaces = mkFn { a = "hello world"; }
      == { a = lib.mkDefault "hello world"; };

    testPreservesAttrsStructure = mkFn {
      nix.settings = { auto-optimise-store = true; trusted-users = [ "@wheel" ]; };
    } == {
      nix.settings = { auto-optimise-store = lib.mkDefault true; trusted-users = lib.mkDefault [ "@wheel" ]; };
    };
  };
in
tests
