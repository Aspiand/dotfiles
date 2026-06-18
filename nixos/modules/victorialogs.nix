{ ... }:
{
  flake.nixosModules.victorialogs =
    { lib, config, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services = {
          victorialogs = {
            enable = true;
            listenAddress = "127.0.0.1:9428";
            extraOptions = [
              "-retentionPeriod=14d"
            ];
          };

          journald.upload = {
            enable = true;
            settings.Upload.URL = "http://localhost:9428/insert/journald";
          };
        };
      };
    };
}
