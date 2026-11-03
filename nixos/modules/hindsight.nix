# Work in Progress
{
  flake.nixosModules.hindsight =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.hindsight = {
          enable = true;

          database = {
            enable = true;
            createDB = true;
          };

          localModels.enable = true;
          controlPlane.enable = true;
        };
      };
    };
}
