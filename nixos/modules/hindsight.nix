{
  flake.nixosModules.hindsight =
    { config, lib, ... }:
    {

      services.hindsight = {
        enable = true;

        host = "127.0.0.1";
        port = 8890;
        logLevel = "warning";
        workers = 1;

        database = {
          enable = true;
          createDB = true;
        };

        localModels.enable = true;

        controlPlane = {
          enable = true;
          apiURL = "https://hindsight.astrapia-kokanue.ts.net/_";
        };

        environment = {
          HINDSIGHT_API_LLM_PROVIDER = "openai";
          HINDSIGHT_API_LLM_BASE_URL = "http://127.0.0.1:20128/v1";
          HINDSIGHT_API_LLM_MODEL = "hindsight";
          HINDSIGHT_API_LLM_REASONING_EFFORT = "high";
          HINDSIGHT_API_LOG_LEVEL = "warn";

          # HINDSIGHT_API_LLM_CACHE_AFFINITY = "none";
          # Fail fast when 9router down instead of burning full LLM timeout.
          HINDSIGHT_API_LLM_CONNECT_TIMEOUT = 10;

          # HINDSIGHT_API_DEFAULT_TIMEZONE = "";

          # Bound DB growth, keep control-plane trace tab useful.
          HINDSIGHT_API_OPERATION_RETENTION_DAYS = 30;
          HINDSIGHT_API_LLM_TRACE_RETENTION_DAYS = 7;

          # Mark retain failed on extraction errors, not silent completed.
          HINDSIGHT_API_FAIL_ON_EXTRACTION_ERRORS = true;
        };

        environmentFiles = [ config.sops.secrets."hindsight/env".path ];
      };

      # Control plane at /, API mounted under /_/ (prefix stripped, /_/mcp -> /mcp).
      # Was bare `virtualHosts` (no such top-level option) -> Caddy never rendered it.
      services.caddy = {
        enable = lib.mkDefault true;
        virtualHosts."http://127.0.0.1:8089".extraConfig = ''
          handle_path /_/* {
            reverse_proxy http://127.0.0.1:8890
          }
          reverse_proxy http://127.0.0.1:9999
        '';
      };

      sops.secrets."hindsight/env" = {
        sopsFile = ../../secrets/hindsight.yml;
        format = "yaml";
        key = "env";
        owner = "hindsight";
        group = "hindsight";
        mode = "0400";
      };
    };
}
