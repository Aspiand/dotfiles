{ ... }:
{
  flake.nixosModules.victoriametrics =
    { lib, ... }:
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
                    targets = [ "127.0.0.1:8428" ];
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
    };
}
