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
          optimizationMode = "cache";
          environment = {
            HEADROOM_CACHE_DIR = "/var/cache/headroom";
          };
        };
      };
    };
}
