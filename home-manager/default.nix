{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./configs/default.nix
    ./modules/default.nix
  ];
}
