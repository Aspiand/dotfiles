{ ... }:
{
  flake.nixosModules.victorialogs =
    { ... }:
    {
      config = {
        services = {
          victorialogs = {
            enable = true;
            listenAddress = "0.0.0.0:9428";
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
