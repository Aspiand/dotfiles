/*
  Secrets live in secrets/n8n.yml:

  env: |
      N8N_ENCRYPTION_KEY=... # openssl rand -hex 32

  runners-auth-token: ...

  sandbox-env: |
      SANDBOX_API_KEYS=...                      # openssl rand -hex 32
      N8N_SANDBOX_SERVICE_API_KEY=...           # = SANDBOX_API_KEYS

      SANDBOX_API_RUNNER_REGISTRATION_TOKEN=... # openssl rand -hex 32
      SANDBOX_RUNNER_REGISTRATION_TOKEN=...     # = SANDBOX_API_RUNNER_REGISTRATION_TOKEN

      SANDBOX_API_RUNNER_API_KEY=...            # openssl rand -hex 32
      SANDBOX_RUNNER_API_KEYS=...               # = SANDBOX_API_RUNNER_API_KEY

  The Assistant sandbox is the n8n-sandbox service: an API that n8n reaches on
  127.0.0.1:8090 plus a privileged Docker-in-Docker runner that spawns one
  container per Assistant session. n8n-sandbox-certs mints the mTLS material
  into /var/lib/n8n-sandbox/tls; delete that directory and restart that unit to
  rotate it.
*/

{
  flake.nixosModules.n8n =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      sandboxVersion = "1.11.0";
      sandboxApiImage = "docker.io/n8nio/n8n-sandbox-service-api:${sandboxVersion}";
      sandboxRunnerImage = "docker.io/n8nio/n8n-sandbox-service-runner-dind:${sandboxVersion}";
      sandboxSessionImage = "docker.io/n8nio/n8n-sandbox-service-sandbox:${sandboxVersion}";
      sandboxPort = 8090;
      sandboxStateDir = "/var/lib/n8n-sandbox";
      sandboxEnv = config.sops.secrets."n8n/sandbox-env".path;
      docker = lib.getExe' config.virtualisation.docker.package "docker";

      # Compose creates this implicitly; oci-containers needs it to exist first.
      networkScript = pkgs.writeShellScript "n8n-sandbox-network" ''
        ${docker} network inspect n8n-sandbox >/dev/null 2>&1 || ${docker} network create n8n-sandbox
      '';

      # bootstrap-mtls.sh is idempotent and keeps an existing CA.
      certsScript = pkgs.writeShellScript "n8n-sandbox-certs" ''
        exec ${docker} run --rm --user 0:0 -e NUM_RUNNERS=1 \
          -v ${sandboxStateDir}/tls:/tls \
          --entrypoint sh ${sandboxApiImage} \
          -c 'bootstrap-mtls.sh --out-dir /tls --api-san sandbox-api --control-san-prefix sandbox-runner && chown -R sandbox-api:sandbox-api /tls/api'
      '';
    in
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
          N8N_INSTANCE_AI_SANDBOX_ENABLED = "true";
          N8N_INSTANCE_AI_SANDBOX_PROVIDER = "n8n-sandbox";
          N8N_SANDBOX_SERVICE_URL = "http://127.0.0.1:${toString sandboxPort}";
        };

        taskRunners = {
          enable = true;
          environment = {
            N8N_RUNNERS_AUTO_SHUTDOWN_TIMEOUT = 60;
          };
        };
      };

      # The sandbox env file also carries N8N_SANDBOX_SERVICE_API_KEY; n8n
      # ignores the remaining SANDBOX_* entries.
      systemd.services.n8n.serviceConfig.EnvironmentFile = [
        config.sops.secrets."n8n/env".path
        sandboxEnv
      ];

      systemd.services.n8n-sandbox-network = {
        description = "Docker network for the n8n Assistant sandbox";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        before = [
          "docker-sandbox-api.service"
          "docker-sandbox-runner-1.service"
        ];
        requiredBy = [
          "docker-sandbox-api.service"
          "docker-sandbox-runner-1.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = networkScript;
          ExecStop = "-${docker} network rm n8n-sandbox";
        };
      };

      systemd.services.n8n-sandbox-certs = {
        description = "mTLS material for the n8n Assistant sandbox";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        before = [
          "docker-sandbox-api.service"
          "docker-sandbox-runner-1.service"
        ];
        requiredBy = [
          "docker-sandbox-api.service"
          "docker-sandbox-runner-1.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = certsScript;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${sandboxStateDir} 0755 root root -"
        "d ${sandboxStateDir}/tls 0755 root root -"
      ];

      virtualisation.oci-containers.containers = {
        sandbox-api = {
          image = sandboxApiImage;
          ports = [ "127.0.0.1:${toString sandboxPort}:8080" ];
          volumes = [ "${sandboxStateDir}/tls/api:/tls:ro" ];
          networks = [ "n8n-sandbox" ];
          environmentFiles = [ sandboxEnv ];
          environment = {
            SANDBOX_API_GRPC_TLS_CERT_FILE = "/tls/grpc-server.crt";
            SANDBOX_API_GRPC_TLS_KEY_FILE = "/tls/grpc-server.key";
            SANDBOX_API_GRPC_TLS_CLIENT_CA_FILE = "/tls/ca.crt";
            SANDBOX_API_RUNNER_CONTROL_GRPC_TLS_CA_FILE = "/tls/ca.crt";
            SANDBOX_API_RUNNER_CONTROL_GRPC_TLS_CERT_FILE = "/tls/control-grpc-api-client.crt";
            SANDBOX_API_RUNNER_CONTROL_GRPC_TLS_KEY_FILE = "/tls/control-grpc-api-client.key";
            SANDBOX_API_RUNNER_CONTROL_GRPC_TLS_SERVER_NAME = "sandbox-runner-1";
          };
        };

        sandbox-runner-1 = {
          image = sandboxRunnerImage;
          privileged = true;
          networks = [ "n8n-sandbox" ];
          volumes = [ "${sandboxStateDir}/tls/runner:/tls:ro" ];
          environmentFiles = [ sandboxEnv ];
          # The runner retries registration on its own, so ordering is enough.
          dependsOn = [ "sandbox-api" ];
          environment = {
            SANDBOX_RUNNER_API_GRPC_ADDR = "sandbox-api:9090";
            SANDBOX_RUNNER_HTTP_BASE_URL = "https://sandbox-runner-1:8080";
            SANDBOX_RUNNER_CONTROL_GRPC_LISTEN_ADDR = ":9091";
            SANDBOX_RUNNER_CONTROL_GRPC_ADVERTISE_ADDR = "sandbox-runner-1:9091";
            SANDBOX_RUNNER_ID = "runner-1";
            SANDBOX_RUNNER_DOCKER_SANDBOX_IMAGE = sandboxSessionImage;
            SANDBOX_RUNNER_REGISTRATION_GRPC_CA_FILE = "/tls/ca.crt";
            SANDBOX_RUNNER_REGISTRATION_GRPC_CERT_FILE = "/tls/grpc-client.crt";
            SANDBOX_RUNNER_REGISTRATION_GRPC_KEY_FILE = "/tls/grpc-client.key";
            SANDBOX_RUNNER_REGISTRATION_GRPC_SERVER_NAME = "sandbox-api";
            SANDBOX_RUNNER_CONTROL_GRPC_TLS_CERT_FILE = "/tls/control-grpc-server.crt";
            SANDBOX_RUNNER_CONTROL_GRPC_TLS_KEY_FILE = "/tls/control-grpc-server.key";
            SANDBOX_RUNNER_CONTROL_GRPC_TLS_CLIENT_CA_FILE = "/tls/ca.crt";
          };
        };
      };

      sops.secrets = {
        "n8n/env" = {
          sopsFile = ../../secrets/n8n.yml;
          format = "yaml";
          key = "env";
          mode = "0400";
        };
        "n8n/runners-auth-token" = {
          sopsFile = ../../secrets/n8n.yml;
          format = "yaml";
          key = "runners-auth-token";
          mode = "0400";
        };
        "n8n/sandbox-env" = {
          sopsFile = ../../secrets/n8n.yml;
          format = "yaml";
          key = "sandbox-env";
          mode = "0400";
        };
      };
    };
}
