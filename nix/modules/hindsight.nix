/*
  Hindsight — agent memory server (API + control plane).

  Two systemd services are created when enabled:
  hindsight-api             HTTP API, default 127.0.0.1:8888
  hindsight-control-plane   web UI,    default 127.0.0.1:9999

  Database
  --------
  `database.enable = true` makes this module manage `services.postgresql`:
  it installs pgvector, creates the database/role, and creates the required
  extensions. A `database.host` starting with "/" is a Unix socket: the
  service runs as the `hindsight` user and PostgreSQL peer authentication is
  used, so no password is needed.

  With a TCP host, `database.passwordFile` (or a full `HINDSIGHT_API_DATABASE_URL`
  in `environmentFiles`) is required. Credentials are never written to the Nix
  store by this module.

  The slim package has no local embedding/reranker models. Set
  HINDSIGHT_API_EMBEDDINGS_PROVIDER and HINDSIGHT_API_RERANKER_PROVIDER through
  `environment`/`environmentFiles`, or use the future `hindsight-api` package.
  See docs/hindsight.md for the full design, phases and operational notes.
*/
{ ... }:
{
  flake.customModules.hindsight =
    { config
    , lib
    , pkgs
    , ...
    }:
    let
      cfg = config.services.hindsight;
      inherit (lib)
        mkIf
        mkOption
        optional
        optionalAttrs
        optionals
        types
        ;
      inherit (cfg) database controlPlane;

      isSocket = lib.hasPrefix "/" database.host;

      # Peer authentication over the Unix socket. asyncpg accepts `host` as a
      # query parameter pointing at the socket directory.
      socketURL = "postgresql://${database.user}@/${database.name}?host=${database.host}&port=${toString database.port}";

      databaseEnv =
        if database.url != null then
          { HINDSIGHT_API_DATABASE_URL = database.url; }
        else if isSocket then
          { HINDSIGHT_API_DATABASE_URL = socketURL; }
        else
          { };

      localModelEnv = optionalAttrs cfg.localModels.enable {
        HINDSIGHT_API_EMBEDDINGS_PROVIDER = "local";
        HINDSIGHT_API_EMBEDDINGS_LOCAL_MODEL = cfg.localModels.embeddingsModel;
        HINDSIGHT_API_RERANKER_PROVIDER = "local";
        HINDSIGHT_API_RERANKER_LOCAL_MODEL = cfg.localModels.rerankerModel;
        HF_HOME = "/var/cache/hindsight/hf";
      };

      # TCP + passwordFile: build the URL at runtime so the password never
      # enters the store. HINDSIGHT_API_DATABASE_URL from an EnvironmentFile
      # wins when it is already set.
      passwordStartScript = pkgs.writeShellScript "hindsight-api-start" ''
        set -eu
        if [ -z "''${HINDSIGHT_API_DATABASE_URL:-}" ]; then
          password="$(cat ${lib.escapeShellArg database.passwordFile})"
          password="''${password%$'\n'}"
          encoded="$(printf '%s' "$password" | ${lib.getExe pkgs.jq} -Rr '@uri')"
          export HINDSIGHT_API_DATABASE_URL="postgresql://${database.user}:$encoded@${database.host}:${toString database.port}/${database.name}"
        fi
        exec ${lib.escapeShellArgs ([ (lib.getExe cfg.package) ] ++ apiArgs)}
      '';

      apiArgs =
        optionals (cfg.workers != null) [
          "--workers"
          (toString cfg.workers)
        ]
        ++ optionals (cfg.logLevel != null) [
          "--log-level"
          cfg.logLevel
        ]
        ++ cfg.extraArgs;

      usePasswordWrapper = !isSocket && database.url == null && database.passwordFile != null;

      apiExecStart =
        if usePasswordWrapper then
          lib.escapeShellArgs [ passwordStartScript ]
        else
          lib.escapeShellArgs ([ (lib.getExe cfg.package) ] ++ apiArgs);

      commonHardening = {
        NoNewPrivileges = true;
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0077";
        CapabilityBoundingSet = [ ];
        AmbientCapabilities = [ ];
      };
    in
    {
      options.services.hindsight = {
        enable = lib.mkEnableOption "hindsight — agent memory server";

        package = mkOption {
          type = types.package;
          default = pkgs.hindsight-api;
          defaultText = lib.literalExpression "pkgs.hindsight-api";
          description = ''
            Hindsight API package. The default `hindsight-api` includes the
            local embedding and reranker models. Use `pkgs.hindsight-api-slim`
            for a smaller closure that requires remote providers.
          '';
        };

        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          example = "0.0.0.0";
          description = "Address the API listens on (HINDSIGHT_API_HOST).";
        };

        port = mkOption {
          type = types.port;
          default = 8888;
          description = "Port the API listens on (HINDSIGHT_API_PORT).";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = "Open the API port in the firewall.";
        };

        workers = mkOption {
          type = types.nullOr types.int;
          default = 1;
          example = null;
          description = ''
            Number of uvicorn worker processes (`--workers`). This is not the
            background job worker: the API runs that in-process by default.

            Each worker is a full Python process. With local embedding/reranker
            models each worker also loads those models, multiplying memory use.
            null omits the flag and uses the upstream default.
          '';
        };

        logLevel = mkOption {
          type = types.nullOr (
            types.enum [
              "critical"
              "error"
              "warning"
              "info"
              "debug"
              "trace"
            ]
          );
          default = null;
          description = "Log level (`--log-level`). null uses the upstream default.";
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [ "--reload" ];
          description = "Extra arguments passed to hindsight-api.";
        };

        environment = mkOption {
          type = types.attrsOf (
            types.oneOf [
              types.str
              types.int
              types.bool
            ]
          );
          default = { };
          example = {
            HINDSIGHT_API_LLM_PROVIDER = "openai";
            HINDSIGHT_API_EMBEDDINGS_PROVIDER = "openai";
            HINDSIGHT_API_RERANKER_PROVIDER = "rrf";
          };
          description = ''
            Extra environment variables for the API service. Values are
            toString'd. Do not put secrets here: they would end up in the Nix
            store. Use `environmentFiles` for secrets.
          '';
        };

        environmentFiles = mkOption {
          type = types.listOf (types.either types.path types.str);
          default = [ ];
          example = [ "/run/secrets/hindsight/env" ];
          description = ''
            Environment files loaded by systemd (EnvironmentFile=), e.g. the
            path of a sops secret. Use this for the LLM API key and, when the
            database is reached over TCP, for a complete
            HINDSIGHT_API_DATABASE_URL (it overrides the generated one).
          '';
        };

        localModels = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Run embeddings and reranking with local models. This matches the
              default `hindsight-api` package, which includes torch and
              sentence-transformers.

              Set to false when using `pkgs.hindsight-api-slim`: configure
              HINDSIGHT_API_EMBEDDINGS_PROVIDER and
              HINDSIGHT_API_RERANKER_PROVIDER yourself through
              `environment`/`environmentFiles`.
            '';
          };

          embeddingsModel = mkOption {
            type = types.str;
            default = "BAAI/bge-small-en-v1.5";
            description = "Local embedding model (HINDSIGHT_API_EMBEDDINGS_LOCAL_MODEL).";
          };

          rerankerModel = mkOption {
            type = types.str;
            default = "cross-encoder/ms-marco-MiniLM-L-6-v2";
            description = "Local reranker model (HINDSIGHT_API_RERANKER_LOCAL_MODEL).";
          };
        };

        database = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Manage a local PostgreSQL instance for Hindsight: enable
              services.postgresql, install pgvector, create the database and
              role (if createDB), and create the required extensions.

              Set to false to use an external database. In that case this
              module does not touch services.postgresql and you must create the
              database, role, and `CREATE EXTENSION vector` yourself.
            '';
          };

          createDB = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Create the database and role automatically. Only meaningful when
              `database.enable = true`. Existing databases and roles are never
              removed by the NixOS PostgreSQL module.
            '';
          };

          name = mkOption {
            type = types.str;
            default = "hindsight";
            description = "Database name.";
          };

          host = mkOption {
            type = types.str;
            default = "/run/postgresql";
            example = "127.0.0.1";
            description = ''
              Database host. An absolute path is interpreted as a Unix socket
              directory and uses peer authentication (no password). Anything
              else is treated as TCP and requires `passwordFile`, `url`, or a
              HINDSIGHT_API_DATABASE_URL in `environmentFiles`.
            '';
          };

          port = mkOption {
            type = types.port;
            default = 5432;
            description = "Database port.";
          };

          user = mkOption {
            type = types.str;
            default = "hindsight";
            description = "Database role. Should match the service user for peer authentication.";
          };

          passwordFile = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "/run/secrets/hindsight/db-password";
            description = ''
              File containing the password for a TCP connection. Read at
              service start and URL-encoded; never added to the Nix store.
            '';
          };

          url = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "postgresql://hindsight@db.example.com:5432/hindsight?sslmode=require";
            description = ''
              Complete PostgreSQL URL. Overrides host/port/name/user.
              Do not put credentials in this option: it is stored in the Nix
              store. Use `passwordFile`, or put HINDSIGHT_API_DATABASE_URL in
              an `environmentFiles` entry instead.
            '';
          };

          package = mkOption {
            type = types.package;
            default =
              if config.services.postgresql.enable then config.services.postgresql.package else pkgs.postgresql;
            defaultText = lib.literalExpression ''
              if config.services.postgresql.enable then
                config.services.postgresql.package
              else
                pkgs.postgresql
            '';
            description = "PostgreSQL package providing psql for the extension setup.";
          };
        };

        controlPlane = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable the Hindsight control plane (web UI).";
          };

          package = mkOption {
            type = types.package;
            default = pkgs.hindsight-control-plane;
            defaultText = lib.literalExpression "pkgs.hindsight-control-plane";
            description = "Control plane package.";
          };

          host = mkOption {
            type = types.str;
            default = "127.0.0.1";
            example = "0.0.0.0";
            description = "Address the control plane listens on (--hostname).";
          };

          port = mkOption {
            type = types.port;
            default = 9999;
            description = "Port the control plane listens on (--port).";
          };

          openFirewall = mkOption {
            type = types.bool;
            default = false;
            description = "Open the control plane port in the firewall.";
          };

          apiURL = mkOption {
            type = types.str;
            default = "http://127.0.0.1:${toString cfg.port}";
            defaultText = lib.literalExpression ''"http://127.0.0.1:''${toString config.services.hindsight.port}"'';
            example = "https://hindsight.example.com";
            description = ''
              URL the browser uses to reach the API (--api-url /
              HINDSIGHT_CP_DATAPLANE_API_URL). This is not necessarily the
              internal address: when the UI is accessed from another machine,
              point it at the public API URL.
            '';
          };

          environment = mkOption {
            type = types.attrsOf (
              types.oneOf [
                types.str
                types.int
                types.bool
              ]
            );
            default = { };
            description = "Extra environment variables for the control plane.";
          };

          environmentFiles = mkOption {
            type = types.listOf (types.either types.path types.str);
            default = [ ];
            example = [ "/run/secrets/hindsight/cp-env" ];
            description = ''
              Environment files for the control plane, e.g. a sops secret
              containing HINDSIGHT_CP_ACCESS_KEY.
            '';
          };

          extraArgs = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Extra arguments passed to hindsight-control-plane.";
          };
        };
      };

      config = mkIf cfg.enable {
        assertions = [
          {
            assertion = !usePasswordWrapper || database.passwordFile != null;
            message = "services.hindsight.database.passwordFile must be set when the database host is TCP.";
          }
          {
            assertion =
              isSocket || database.url != null || database.passwordFile != null || cfg.environmentFiles != [ ];
            message = ''
              services.hindsight.database: a TCP database host needs passwordFile,
              url, or a HINDSIGHT_API_DATABASE_URL in environmentFiles.
            '';
          }
          {
            assertion = !database.enable || config.services.postgresql.enable;
            message = "services.hindsight.database.enable requires services.postgresql.enable.";
          }
          {
            assertion = !controlPlane.enable || cfg.port != controlPlane.port;
            message = "services.hindsight.port and services.hindsight.controlPlane.port must differ.";
          }
        ];

        services.postgresql = mkIf database.enable {
          enable = lib.mkDefault true;

          # A default so hosts with other modules defining `extensions` (for
          # example immich, which already includes pgvector) keep theirs.
          extensions = lib.mkDefault (ps: [ ps.pgvector ]);

          ensureDatabases = mkIf database.createDB [ database.name ];
          ensureUsers = mkIf database.createDB [
            {
              name = database.user;
              ensureDBOwnership = true;
              ensureClauses.login = true;
            }
          ];
        };

        systemd.services.postgresql-setup.serviceConfig.ExecStartPost = mkIf database.enable [
          (
            let
              sql = pkgs.writeText "hindsight-pg-setup.sql" ''
                CREATE EXTENSION IF NOT EXISTS vector;
                CREATE EXTENSION IF NOT EXISTS pg_trgm;
                CREATE EXTENSION IF NOT EXISTS btree_gin;
              '';
            in
            ''
              ${lib.getExe' database.package "psql"} \
                -p ${toString database.port} \
                -d ${lib.escapeShellArg database.name} \
                -f ${sql}
            ''
          )
        ];

        users.users.hindsight = {
          isSystemUser = true;
          group = "hindsight";
          home = "/var/lib/hindsight";
        };
        users.groups.hindsight = { };

        environment.systemPackages = [ cfg.package ];

        systemd.services.hindsight-api = {
          description = "Hindsight API — agent memory server";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ] ++ optional database.enable "postgresql.target";
          requires = optional database.enable "postgresql.target";

          environment = {
            HINDSIGHT_API_HOST = cfg.host;
            HINDSIGHT_API_PORT = toString cfg.port;
            HINDSIGHT_API_WORKER_ID = "hindsight-api";
            HOME = "/var/lib/hindsight";
          }
          // localModelEnv
          // databaseEnv
          // lib.mapAttrs (_: toString) cfg.environment;

          serviceConfig = {
            Type = "simple";
            User = "hindsight";
            Group = "hindsight";
            WorkingDirectory = "/var/lib/hindsight";
            StateDirectory = "hindsight";
            CacheDirectory = "hindsight";
            EnvironmentFile = cfg.environmentFiles;
            ExecStart = apiExecStart;
            Restart = "on-failure";
            RestartSec = 5;
            TimeoutStopSec = 30;
          }
          // commonHardening;
        };

        systemd.services.hindsight-control-plane = mkIf controlPlane.enable {
          description = "Hindsight control plane — web UI";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [
            "network-online.target"
            "hindsight-api.service"
          ];
          requires = [ "hindsight-api.service" ];

          environment = {
            HINDSIGHT_CP_DATAPLANE_API_URL = controlPlane.apiURL;
            HOME = "/var/lib/hindsight-control-plane";
          }
          // lib.mapAttrs (_: toString) controlPlane.environment;

          serviceConfig = {
            Type = "simple";
            User = "hindsight";
            Group = "hindsight";
            WorkingDirectory = "/var/lib/hindsight-control-plane";
            StateDirectory = "hindsight-control-plane";
            CacheDirectory = "hindsight-control-plane";
            EnvironmentFile = controlPlane.environmentFiles;
            ExecStart = lib.escapeShellArgs (
              [
                (lib.getExe controlPlane.package)
                "--hostname"
                controlPlane.host
                "--port"
                (toString controlPlane.port)
                "--api-url"
                controlPlane.apiURL
              ]
              ++ controlPlane.extraArgs
            );
            Restart = "on-failure";
            RestartSec = 5;
            TimeoutStopSec = 30;
          }
          // commonHardening;
        };

        networking.firewall.allowedTCPPorts =
          optional (cfg.openFirewall && cfg.host != "127.0.0.1") cfg.port
          ++ optional
            (
              controlPlane.enable && controlPlane.openFirewall && controlPlane.host != "127.0.0.1"
            )
            controlPlane.port;
      };
    };
}
