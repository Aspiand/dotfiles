/*
  Secrets live in secrets/n8n.yml as YAML key `env`, containing dotenv text:

    env: |
      N8N_ENCRYPTION_KEY=... # openssl rand -hex 32
    runners-auth-token: ...
*/

{
  flake.nixosModules.n8n =
    { config, lib, ... }:
    {
      services.n8n = {
        enable = true;
        openFirewall = false;
        environment = {
          N8N_PORT = 5678;
          N8N_LISTEN_ADDRESS = "127.0.0.1";
          N8N_PROTOCOL = "http";
          N8N_PROXY_HOPS = 1;
          N8N_DIAGNOSTICS_ENABLED = false;
          N8N_VERSION_NOTIFICATIONS_ENABLED = false;
          N8N_SECURE_COOKIE = true;
          DB_TYPE = "sqlite";
          DB_SQLITE_POOL_SIZE = 2;
          DB_SQLITE_VACUUM_ON_STARTUP = true;
          EXECUTIONS_MODE = "regular";
          N8N_WEBHOOK_URL = "https://n8n.aspian.my.id/";
          N8N_LOG_LEVEL = "warn";
          N8N_METRICS = true;
          QUEUE_HEALTH_CHECK_ACTIVE = true;
          N8N_UNVERIFIED_PACKAGES_ENABLED = true;
          N8N_RUNNERS_AUTH_TOKEN_FILE = config.sops.secrets."n8n/runners-auth-token".path;
        };

        taskRunners = {
          enable = true;
          environment = {
            N8N_RUNNERS_AUTO_SHUTDOWN_TIMEOUT = 60;
          };
        };
      };

      systemd.services.n8n.serviceConfig.EnvironmentFile = config.sops.secrets."n8n/env".path;

      sops.secrets."n8n/env" = {
        sopsFile = ../../secrets/n8n.yml;
        format = "yaml";
        key = "env";
        mode = "0400";
      };
      sops.secrets."n8n/runners-auth-token" = {
        sopsFile = ../../secrets/n8n.yml;
        format = "yaml";
        key = "runners-auth-token";
        mode = "0400";
      };
    };
}
