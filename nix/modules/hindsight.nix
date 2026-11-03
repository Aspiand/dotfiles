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

  With a TCP host, provide a full `HINDSIGHT_API_DATABASE_URL` through
  `environmentFiles`. The module cannot inspect environment-file contents.

  The slim package has no local embedding/reranker models. Set
  HINDSIGHT_API_EMBEDDINGS_PROVIDER and HINDSIGHT_API_RERANKER_PROVIDER through
  `environment`/`environmentFiles`, or use the full `hindsight-api` package.
  See docs/hindsight.md for the full design, phases and operational notes.
*/
{ ... }:
{
  flake.customModules.hindsight =
    {
      config,
      lib,
      pkgs,
      ...
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
      envValue = value: if lib.isBool value then lib.boolToString value else toString value;

      # Double-quote a PostgreSQL identifier, escaping embedded quotes.
      sqlIdent = name: "\"" + lib.replaceStrings [ "\"" ] [ "\"\"" ] name + "\"";

      # Peer authentication over the Unix socket. asyncpg accepts `host` as a
      # query parameter pointing at the socket directory.
      socketURL = "postgresql://${database.user}@/${database.name}?host=${database.host}&port=${toString database.port}";

      databaseEnv = if isSocket then { HINDSIGHT_API_DATABASE_URL = socketURL; } else { };

      localModelEnv = optionalAttrs cfg.localModels.enable {
        HINDSIGHT_API_EMBEDDINGS_PROVIDER = "local";
        HINDSIGHT_API_EMBEDDINGS_LOCAL_MODEL = cfg.localModels.embeddingsModel;
        HINDSIGHT_API_RERANKER_PROVIDER = "local";
        HINDSIGHT_API_RERANKER_LOCAL_MODEL = cfg.localModels.rerankerModel;
        HF_HOME = "/var/cache/hindsight/hf";
      };

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

      apiCommand = [ (lib.getExe cfg.package) ] ++ apiArgs;

      apiExecStart = lib.escapeShellArgs apiCommand;

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
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
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
          type = types.nullOr types.ints.positive;
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
              With a TCP database host, one of these files must define
              HINDSIGHT_API_DATABASE_URL; this cannot be validated from the
              file path alone.
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

              Set to false to use an external database. In that case configure
              a TCP `host` and credentials in `environmentFiles`, this module does not touch
              services.postgresql, and you must create the database, role, and
              `CREATE EXTENSION vector` yourself. This option defaults to true
              while Hindsight is enabled, so explicitly set it to false for an
              external database.
            '';
          };

          createDB = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Create the database and role automatically. Only meaningful when
              `database.enable = true`. When false, the operator must provide
              the database and role; the local setup hook still installs the
              required extensions into an existing database. Existing databases
              and roles are never removed by the NixOS PostgreSQL module.
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
              else is treated as TCP and requires a complete
              HINDSIGHT_API_DATABASE_URL in `environmentFiles`.
            '';
          };

          port = mkOption {
            type = types.port;
            default = if database.enable then config.services.postgresql.settings.port else 5432;
            defaultText = lib.literalExpression ''
              if config.services.hindsight.database.enable then
                config.services.postgresql.settings.port
              else
                5432
            '';
            description = ''
              Database port. Follows `services.postgresql.settings.port` for a
              managed local database, so changing the server port does not
              leave the socket URL and the setup hook pointing at the old one.
            '';
          };

          user = mkOption {
            type = types.str;
            default = "hindsight";
            description = ''
              Database role. With a Unix socket host it must match the service
              user (`hindsight`) because PostgreSQL peer authentication compares
              the two.
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
              HINDSIGHT_CP_DATAPLANE_API_URL). Default works when browser and
              control plane are on the same machine; for remote browser access,
              set this to the externally reachable API URL.
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
            assertion = !database.enable || isSocket;
            message = ''
              Managed local PostgreSQL currently supports Unix-socket peer
              authentication only. Use a socket host, or set
              services.hindsight.database.enable = false for an external TCP database.
            '';
          }
          {
            assertion = isSocket || cfg.environmentFiles != [ ];
            message = ''
              services.hindsight.database: a TCP database host needs an
              environmentFiles entry containing HINDSIGHT_API_DATABASE_URL.
              The URL cannot be validated from the file path. For an external
              database, set database.enable = false.
            '';
          }
          {
            assertion = database.enable || !isSocket;
            message = ''
              services.hindsight.database.enable = false selects external database mode;
              set services.hindsight.database.host to a TCP host, not a Unix socket path.
            '';
          }
          {
            assertion = !isSocket || database.user == "hindsight";
            message = ''
              services.hindsight.database.user must be "hindsight" with a Unix-socket
              host: the service runs as that user and PostgreSQL peer authentication
              requires the role name to match.
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
          {
            assertion = !cfg.localModels.enable || (cfg.package.passthru.hasLocalModels or false);
            message = ''
              services.hindsight.localModels.enable = true requires a package with
              local ML dependencies. Set localModels.enable = false when using
              pkgs.hindsight-api-slim.
            '';
          }
        ];

        services.postgresql = mkIf database.enable {
          enable = lib.mkDefault true;

          # A default so hosts with other modules defining `extensions` (for
          # example immich, which already includes pgvector) keep theirs.
          extensions = lib.mkAfter (ps: [ ps.pgvector ]);

          ensureDatabases = mkIf database.createDB [ database.name ];
          ensureUsers = mkIf database.createDB [
            {
              name = database.user;
              # ensureDBOwnership re-owns the database named after the *user*,
              # not `database.name`, so only use it when both agree. A differing
              # name is re-owned by the setup hook below.
              ensureDBOwnership = database.name == database.user;
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
                ${lib.optionalString database.createDB "ALTER DATABASE ${sqlIdent database.name} OWNER TO ${sqlIdent database.user};"}
              '';

              # SQL literal, quotes doubled. Kept separate so the identifier
              # quoting of the script above is not reused for a value.
              dbNameLiteral = "'" + lib.replaceStrings [ "'" ] [ "''" ] database.name + "'";

              connectArgs =
                "-p ${toString database.port}"
                + lib.optionalString isSocket " -h ${lib.escapeShellArg database.host}";
            in
            pkgs.writeShellScript "hindsight-postgres-setup" ''
              set -euo pipefail
              psql=${lib.getExe' database.package "psql"}

              # createDB = false may leave the database to the operator: skip
              # instead of failing postgresql-setup (and the whole target).
              exists="$(
                "$psql" ${connectArgs} -d postgres -tAc \
                  ${lib.escapeShellArg "SELECT 1 FROM pg_database WHERE datname = ${dbNameLiteral}"} \
                  | tr -d '[:space:]'
              )"
              if [ "$exists" != 1 ]; then
                echo "hindsight: database '${database.name}' does not exist; skipping extension setup" >&2
                exit 0
              fi

              "$psql" ${connectArgs} -d ${lib.escapeShellArg database.name} \
                -v ON_ERROR_STOP=1 -f ${sql}
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
          # Restart with PostgreSQL instead of staying down after a database
          # restart (a propagated stop is not a failure, so Restart=on-failure
          # would not bring the API back).
          partOf = optional database.enable "postgresql.target";

          environment = {
            HINDSIGHT_API_HOST = cfg.host;
            HINDSIGHT_API_PORT = toString cfg.port;
            HINDSIGHT_API_WORKER_ID = "hindsight-api";
            HOME = "/var/lib/hindsight";
          }
          // localModelEnv
          // databaseEnv
          // lib.mapAttrs (_: envValue) cfg.environment;

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
          // lib.mapAttrs (_: envValue) controlPlane.environment;

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
          optional cfg.openFirewall cfg.port
          ++ optional (controlPlane.enable && controlPlane.openFirewall) controlPlane.port;
      };
    };
}
