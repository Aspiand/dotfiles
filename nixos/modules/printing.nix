{
  flake.nixosModules.printing =
    { lib, pkgs, ... }:
    {
      services.printing = {
        enable = false;
        drivers = with pkgs; [ gutenprint ];
      };
    };
}
