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
        controlPlane.enable = true;

        environment = {
          HINDSIGHT_API_LLM_PROVIDER = "openai";
          HINDSIGHT_API_LLM_BASE_URL = "http://127.0.0.1:20128/v1";
          HINDSIGHT_API_LLM_MODEL = "hindsight";
        };

        environmentFiles = [ config.sops.secrets."hindsight/env".path ];
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
