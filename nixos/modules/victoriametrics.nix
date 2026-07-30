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
          retentionPeriod = "4y";

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
              {
                job_name = "tsdproxy";
                scrape_interval = "30s";
                metrics_path = "/metrics";
                static_configs = [
                  {
                    targets = [ "localhost:8080" ];
                    labels = {
                      instance = config.networking.hostName or "localhost";
                    };
                  }
                ];
              }
            ]
            ++ lib.optionals (config.services.prometheus.exporters.process.enable or false) [
              {
                job_name = "process-exporter";
                scrape_interval = "10s";
                static_configs = [
                  {
                    targets = [
                      "${config.services.prometheus.exporters.process.listenAddress}:${toString config.services.prometheus.exporters.process.port}"
                    ];
                    labels = {
                      instance = config.networking.hostName or "localhost";
                    };
                  }
                ];
              }
            ]
            ++ lib.optionals (config.services.prometheus.exporters.node.enable or false) [
              {
                job_name = "node-exporter";
                scrape_interval = "10s";
                static_configs = [
                  {
                    targets = [
                      "${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
                    ];
                    labels = {
                      instance = config.networking.hostName or "localhost";
                    };
                  }
                  {
                    targets = [ "aira:9100" ];
                    labels.instance = "aira";
                  }
                ];
              }
            ]
            ++ lib.optionals (config.services.immich.enable or false) [
              {
                job_name = "immich-server";
                scrape_interval = "15s";
                metrics_path = "/metrics";
                static_configs = [
                  {
                    targets = [ "localhost:8081" ];
                    labels = {
                      instance = config.networking.hostName or "localhost";
                    };
                  }
                ];
              }
              {
                job_name = "immich-microservices";
                scrape_interval = "15s";
                metrics_path = "/metrics";
                static_configs = [
                  {
                    targets = [ "localhost:8082" ];
                    labels = {
                      instance = config.networking.hostName or "localhost";
                    };
                  }
                ];
              }
            ]
            ++ lib.optionals (config.services.prometheus.exporters.postgres.enable or false) [
              {
                job_name = "postgres-exporter";
                scrape_interval = "10s";
                static_configs = [
                  {
                    targets = [
                      "${config.services.prometheus.exporters.postgres.listenAddress}:${toString config.services.prometheus.exporters.postgres.port}"
                    ];
                    labels = {
                      instance = config.networking.hostName or "localhost";
                    };
                  }
                ];
              }
            ]
            ++ lib.optionals (config.services.prometheus.pushgateway.enable or false) [
              {
                job_name = "pushgateway";
                scrape_interval = "10s";
                static_configs = [
                  {
                    targets = [ config.services.prometheus.pushgateway.web.listen-address ];
                    labels = {
                      instance = config.networking.hostName or "localhost";
                    };
                  }
                ];
              }
            ];
          };
        };

        services.prometheus.pushgateway = {
          enable = true;
          web.listen-address = "0.0.0.0:9091";
        };
      };
    };
}
