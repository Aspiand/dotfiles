{
  flake.nixosModules.headroom =
    { config, lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.headroom = {
          enable = true;
          mode = "proxy";
          extraEnv = {
            HEADROOM_WORKSPACE_DIR = "/var/lib/headroom";
          };
        };
      };
    };
}
