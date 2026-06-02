{ lib }:
let
  # Recursively wraps every non-attrs leaf value with lib.mkDefault
  # Attrsets are recursed into depth-first; only leaves get mkDefault.
  mkDefaults = attrs:
    lib.mapAttrs
      (name: value:
        if builtins.isAttrs value
        then mkDefaults value
        else lib.mkDefault value
      )
      attrs;
in {
  inherit mkDefaults;
}
