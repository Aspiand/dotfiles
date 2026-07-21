{ ... }:
{
  flake.nixosModules.process-exporter =
    { config, ... }:
    {
      services.prometheus.exporters.process = {
        enable = true;
        listenAddress = if config.services.victoriametrics.enable or false then "127.0.0.1" else "0.0.0.0";
        port = 9256;

        settings.process_names = [
          {
            name = "{{.Comm}}";
            cmdline = [ ".+" ];
          }
        ];
      };
    };
}
