{ ... }:
{
  flake.nixosModules.prometheus =
    { config, lib, ... }:
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
                  targets = [
                    "${toString config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}"
                  ];
                }
              ];
            }
            {
              job_name = "node";
              static_configs = [
                {
                  targets = [
                    "${toString config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
                  ];
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
