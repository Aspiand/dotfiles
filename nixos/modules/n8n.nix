/*
  Secrets live in secrets/n8n.yml as YAML key `env`, containing dotenv text:

    env: |
      N8N_ENCRYPTION_KEY=...
      WEBHOOK_URL=https://n8n.example.com/

  tags:
    - untested
*/

{
  flake.nixosModules.n8n =
    { config, lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {

      services.n8n = {
        enable = true;
        openFirewall = false;
        environment = {
          N8N_PORT = 5678;
          N8N_USER_FOLDER = "/var/lib/n8n";
          N8N_LISTEN_ADDRESS = "127.0.0.1";
          N8N_PROTOCOL = "https";
          N8N_DIAGNOSTICS_ENABLED = false;
          N8N_VERSION_NOTIFICATIONS_ENABLED = true;
          N8N_SECURE_COOKIE = true;
          DB_TYPE = "sqlite";
          DB_SQLITE_POOL_SIZE = 2;
          DB_SQLITE_VACUUM_ON_STARTUP = true;
          EXECUTIONS_MODE = "regular";
          N8N_RUNNERS_ENABLED = true;
          OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS = true;

          N8N_LOG_LEVEL = "warn";
          N8N_METRICS = true;
          QUEUE_HEALTH_CHECK_ACTIVE = true;
        };
      };

      systemd.services.n8n.serviceConfig.EnvironmentFile = config.sops.secrets."n8n/env".path;

      sops.secrets."n8n/env" = {
        sopsFile = ../../secrets/n8n.yml;
        format = "yaml";
        key = "env";
        mode = "0400";
      };
    };
}
