{ lib, ... }:

let
  autoload = dir:
    builtins.map (name: dir + "/${name}") (
      builtins.attrNames (
        lib.filterAttrs (name: type: name != "default.nix" && lib.hasSuffix ".nix" name) (
          builtins.readDir dir
        )
      )
    );
in
{
  imports = autoload ./modules ++ [ ./profiles/default.nix ];
}
