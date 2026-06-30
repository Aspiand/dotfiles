{ ... }:
{
  flake.customModules.paperclip =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.paperclip;
      pname = "paperclip";
      inherit (lib) mkIf mkOption types optionalAttrs warnIf;

      instanceDir = "${cfg.stateDir}/instances/${cfg.instanceId}";

      # Only emit connectionString into config.json when user explicitly
      # provided a URL. Empty string means "use DATABASE_URL from env".
      dbConnStr = lib.optionalAttrs (cfg.database.external.url != "") {
        connectionString = cfg.database.external.url;
      };

      configJson = pkgs.writeText "paperclip-config.json" (builtins.toJSON (lib.recursiveUpdate {
        "$meta" = {
          version = 1;
          source = "nixos-module";
        };
        server = {
          deploymentMode = if cfg.auth.enable then "authenticated" else "local_trusted";
          exposure = if cfg.publicExposure then "public" else "private";
          host = cfg.host;
          port = cfg.port;
          serveUi = cfg.serveUi;
        };
        database = {
          mode = if cfg.database.external.enable then "postgres" else "embedded-postgres";
          embeddedPostgresDataDir = "${instanceDir}/db";
          backup = {
            enabled = cfg.database.backup.enable;
            intervalMinutes = cfg.database.backup.intervalMinutes;
            retentionDays = cfg.database.backup.retentionDays;
            dir = "${instanceDir}/data/backups";
          };
        } // dbConnStr;
        storage = {
          provider = if cfg.storage.s3.enable then "s3" else "local_disk";
          localDisk = {
            baseDir = "${instanceDir}/data/storage";
          };
        } // lib.optionalAttrs cfg.storage.s3.enable {
          s3 = {
            inherit (cfg.storage.s3) bucket region prefix forcePathStyle;
          } // lib.optionalAttrs (cfg.storage.s3.endpoint != null) {
            inherit (cfg.storage.s3) endpoint;
          };
        };
        logging = {
          logDir = "${instanceDir}/logs";
        };
        secrets = {
          provider = "local_encrypted";
          localEncrypted = {
            keyFilePath = "${instanceDir}/secrets/master.key";
          };
        };
      } cfg.settings));

      # systemd StateDirectory only accepts relative paths (under /var/lib).
      # If stateDir is under /var/lib, extract the suffix; otherwise drop
      # StateDirectory and rely on tmpfiles + ReadWritePaths.
      stateDirRel = lib.removePrefix "/var/lib/" cfg.stateDir;
      useStateDirectory = stateDirRel != cfg.stateDir; # true = prefix was removed
    in
    {
      options.services.paperclip = {
        enable = lib.mkEnableOption "Paperclip — AI agent orchestration platform";

        package = mkOption {
          type = types.package;
          default = pkgs.${pname};
          defaultText = lib.literalExpression "pkgs.${pname}";
          description = "Paperclip package to use.";
        };

        port = mkOption {
          type = types.port;
          default = 3100;
          description = "Port the server listens on.";
        };

        host = mkOption {
          type = types.str;
          default = "0.0.0.0";
          description = "Address the server binds to.";
        };

        serveUi = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to serve the bundled web UI.";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to open the server port in the firewall.";
        };

        auth.enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable authenticated deployment mode.
            When false, uses local_trusted mode (loopback only).
          '';
        };

        publicExposure = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Expose the server publicly.
            When false, the server runs in private mode.
          '';
        };

        stateDir = mkOption {
          type = types.str;
          default = "/var/lib/paperclip";
          description = ''
            Base directory for Paperclip state (database, logs, storage, secrets).
            When set to a path under /var/lib/, systemd StateDirectory is used for
            automatic directory creation. For other paths, tmpfiles handles it.
          '';
        };

        instanceId = mkOption {
          type = types.str;
          default = "default";
          description = "Instance identifier. Allows running multiple isolated instances.";
        };

        user = mkOption {
          type = types.str;
          default = "paperclip";
          description = "User account under which Paperclip runs.";
        };

        group = mkOption {
          type = types.str;
          default = "paperclip";
          description = "Group under which Paperclip runs.";
        };

        # Database
        database.external = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Use an external PostgreSQL database instead of the embedded one.
              When enabled, set `database.external.url` or (preferred) pass
              `DATABASE_URL` through `environmentFiles` to keep secrets out of
              the Nix store.
            '';
          };

          url = mkOption {
            type = types.str;
            default = "";
            description = ''
              PostgreSQL connection string for external mode.

              ⚠  SECURITY WARNING: Setting this via the Nix option writes the
              connection string (including password) to a world-readable path
              in /nix/store. Any local user can read /etc/paperclip/config.json
              and recover database credentials.

              Use `environmentFiles` with DATABASE_URL instead — secrets stay
              outside the Nix store and are only readable by the paperclip user.
            '';
          };
        };

        database.backup = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable automated database backups.";
          };

          intervalMinutes = mkOption {
            type = types.ints.between 1 10080;
            default = 60;
            description = "Minutes between automated backups.";
          };

          retentionDays = mkOption {
            type = types.ints.between 1 3650;
            default = 7;
            description = "Days to retain old backups.";
          };
        };

        # Storage
        storage.s3 = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Use S3 for file storage instead of local disk.";
          };

          bucket = mkOption {
            type = types.str;
            default = "paperclip";
            description = "S3 bucket name.";
          };

          region = mkOption {
            type = types.str;
            default = "us-east-1";
            description = "S3 region.";
          };

          endpoint = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Custom S3 endpoint for S3-compatible services (e.g. MinIO).";
          };

          prefix = mkOption {
            type = types.str;
            default = "";
            description = "Key prefix for all S3 objects.";
          };

          forcePathStyle = mkOption {
            type = types.bool;
            default = false;
            description = "Use path-style S3 URLs instead of virtual-hosted-style.";
          };
        };

        # Escape hatches
        environment = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = "Extra environment variables passed to the server.";
        };

        environmentFiles = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            Paths to files containing environment variables (systemd EnvironmentFile).
            Use this for secrets like API keys or DATABASE_URL — they stay out of
            the world-readable Nix store this way.
          '';
        };

        settings = mkOption {
          type = types.attrs;
          default = { };
          description = ''
            Freeform JSON attributes deep-merged into the generated config.json.
            Use this for options not covered by the typed module options.

            ⚠  SECURITY WARNING: Values set here are serialised into the Nix store
            and world-readable. Do not place secrets here.
          '';
        };
      };

      config = mkIf cfg.enable {
        assertions = [
          {
            assertion = !cfg.publicExposure || cfg.auth.enable;
            message = "services.paperclip: public exposure requires auth.enable = true.";
          }
          {
            assertion = !(!cfg.auth.enable && cfg.host != "127.0.0.1" && cfg.host != "::1" && cfg.host != "localhost");
            message = "services.paperclip: local_trusted mode (auth.enable = false) requires host to be loopback (127.0.0.1, ::1, or localhost).";
          }
        ];

        # Warn if user sets database URL directly — it leaks into Nix store
        warnings = warnIf (cfg.database.external.url != "") ''
          services.paperclip: database.external.url is set directly in Nix config.
          This writes the connection string (including password) to a world-readable
          path in /nix/store. Use environmentFiles with DATABASE_URL instead.
        '';

        users.users.${cfg.user} = {
          isSystemUser = true;
          group = cfg.group;
          home = cfg.stateDir;
          description = "Paperclip service user";
        };

        users.groups.${cfg.group} = { };

        systemd.tmpfiles.rules = [
          "d ${instanceDir}/db 0750 ${cfg.user} ${cfg.group} -"
          "d ${instanceDir}/data/storage 0750 ${cfg.user} ${cfg.group} -"
          "d ${instanceDir}/data/backups 0750 ${cfg.user} ${cfg.group} -"
          "d ${instanceDir}/logs 0750 ${cfg.user} ${cfg.group} -"
          "d ${instanceDir}/secrets 0700 ${cfg.user} ${cfg.group} -"
        ];

        environment.etc."paperclip/config.json" = {
          source = configJson;
          mode = "0644";
        };

        systemd.services.paperclip = {
          description = "Paperclip — AI agent orchestration platform";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          environment = {
            PAPERCLIP_HOME = cfg.stateDir;
            PAPERCLIP_INSTANCE_ID = cfg.instanceId;
            PAPERCLIP_CONFIG = "/etc/paperclip/config.json";
            PORT = toString cfg.port;
            HOST = cfg.host;
            SERVE_UI = lib.boolToString cfg.serveUi;
            PAPERCLIP_DEPLOYMENT_MODE = if cfg.auth.enable then "authenticated" else "local_trusted";
            PAPERCLIP_DEPLOYMENT_EXPOSURE = if cfg.publicExposure then "public" else "private";
            PAPERCLIP_MIGRATION_AUTO_APPLY = "true";
            PAPERCLIP_MIGRATION_PROMPT = "never";
            NODE_ENV = "production";
          } // cfg.environment;

          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            ExecStart = "${cfg.package}/bin/paperclip-server";
            Restart = "on-failure";
            RestartSec = 5;

            WorkingDirectory = cfg.stateDir;

            # StateDirectory only works with relative paths under /var/lib.
            # For custom paths, tmpfiles handles directory creation instead.
            StateDirectory = lib.mkIf useStateDirectory stateDirRel;

            EnvironmentFile = cfg.environmentFiles;

            # Hardening
            ProtectHome = true;
            ProtectSystem = "strict";
            ReadWritePaths = [ cfg.stateDir ];
            PrivateTmp = true;
            NoNewPrivileges = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
          };
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
      };
    };
}
