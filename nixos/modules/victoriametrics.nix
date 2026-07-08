{ ... }:
{
  flake.nixosModules.victoriametrics =
    { lib, config, ... }:
    let
      cfg = config.services.victoriametrics;
    in
    {
      config = {
        services.victoriametrics = {
          enable = true;

          listenAddress = "0.0.0.0:8428";
          retentionPeriod = "30d";

          prometheusConfig = {
            scrape_configs = [
              {
                job_name = "victoriametrics";
                static_configs = [
                  {
                    targets = [ cfg.listenAddress ];
                  }
                ];
              }
            ]
            ++ lib.optionals (config.services.prometheus.exporters.node.enable or false) [
              {
                job_name = "node-exporter";
                scrape_interval = "60s";
                static_configs = [
                  {
                    targets = [
                      "${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
                    ];
                    labels = {
                      instance = config.networking.hostName or "localhost";
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    };
}
