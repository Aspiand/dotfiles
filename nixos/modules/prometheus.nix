{ ... }:
{
  flake.nixosModules.prometheus =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.prometheus = {
          enable = true;

          port = 9090;
          listenAddress = "127.0.0.1";

          stateDir = "prometheus";

          retentionTime = "30d";
          retentionSize = "0"; # unlimited

          globalConfig = {
            scrape_interval = "15s";
            evaluation_interval = "15s";
            scrape_timeout = "10s";
          };

          ruleFiles = [ ];

          scrapeConfigs = [
            {
              job_name = "prometheus";
              static_configs = [
                {
                  targets = [ "127.0.0.1:9090" ];
                }
              ];
            }
            {
              job_name = "node";
              static_configs = [
                {
                  targets = [ "127.0.0.1:9100" ];
                  labels = {
                    instance = "localhost";
                  };
                }
              ];
            }
          ];
        };
      };
    };
}
