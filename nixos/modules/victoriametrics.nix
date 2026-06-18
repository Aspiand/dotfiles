{ ... }:
{
  flake.nixosModules.victoriametrics =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.victoriametrics = {
          enable = true;

          listenAddress = "127.0.0.1:8428";
          retentionPeriod = "30d";

          prometheusConfig = {
            scrape_configs = [
              {
                job_name = "victoriametrics";
                static_configs = [
                  {
                    targets = [ config.services.victoriametrics.listenAddress ];
                  }
                ];
              }
              {
                job_name = "node-exporter";
                scrape_interval = "60s";
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

        services.grafana.declarativePlugins = with pkgs.grafanaPlugins; [
          victoriametrics-metrics-datasource
        ];
      };
    };
}
