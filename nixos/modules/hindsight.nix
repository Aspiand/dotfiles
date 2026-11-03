{
  flake.nixosModules.hindsight =
    { config, lib, ... }:
    {

      services.hindsight = {
        enable = true;

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
        };

        environmentFiles = [ config.sops.secrets."hindsight/env".path ];
      };

      # control plane at /, API mounted under /_/ (prefix is
      # stripped, so /_/mcp -> /mcp on the API.
      virtualHosts."127.0.0.1:8081".extraConfig = ''
        handle_path /_/* {
          reverse_proxy http://127.0.0.1:8888
        }
        reverse_proxy http://127.0.0.1:9999
      '';

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
