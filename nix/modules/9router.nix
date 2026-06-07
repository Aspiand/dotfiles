{ ... }:
{
  flake.customModules."9router" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services."9router";
      pname = "9router";
      inherit (lib) mkIf mkOption types;
    in
    {
      options.services."9router" = {
        enable = lib.mkEnableOption "9router — AI router and dashboard";

        package = mkOption {
          type = types.package;
          default = pkgs.${pname};
          defaultText = lib.literalExpression "pkgs.${pname}";
          description = "9router package to use.";
        };

        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          example = "0.0.0.0";
          description = "Bind address for web UI and API.";
        };

        port = mkOption {
          type = types.port;
          default = 20128;
          description = "Port for web UI and API.";
        };

        dataDir = mkOption {
          type = types.str;
          default = "/var/lib/9router";
          description = "Data directory for logs, sessions, and state.";
        };

        environment = mkOption {
          type =
            with types;
            attrsOf (oneOf [
              str
              int
              bool
            ]);
          default = { };
          example = {
            OPENAI_API_KEY = "...";
          };
          description = "Extra environment variables for 9router. Values are toString'd before injection.";
        };

        environmentFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            Path to an environment file (systemd EnvironmentFile format) loaded at service start.
            Secrets defined here stay out of the Nix store — use this instead of `environment` for API keys.
          '';
        };

        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = "Open port in firewall.";
        };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];

        users.users.${pname} = {
          isSystemUser = true;
          group = pname;
          home = cfg.dataDir;
        };

        users.groups.${pname} = { };

        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 0700 ${pname} ${pname} -"
        ];

        systemd.services.${pname} = {
          description = "9router — AI router and dashboard";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            User = pname;
            Group = pname;
            WorkingDirectory = cfg.dataDir;
            ExecStart = lib.getExe cfg.package;
            Restart = "on-failure";
            RestartSec = 5;

            # Hardening
            NoNewPrivileges = true;
            LockPersonality = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ReadWritePaths = [ cfg.dataDir ];
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
            RestrictRealtime = true;
            RestrictNamespaces = true;
            UMask = "0077";
            CapabilityBoundingSet = [ ];
            AmbientCapabilities = [ ];
          }
          // lib.optionalAttrs (cfg.environmentFile != null) {
            EnvironmentFile = [ cfg.environmentFile ];
          };

          environment = lib.mapAttrs (_: toString) ({
            DATA_DIR = cfg.dataDir;
            HOST = cfg.host;
            PORT = cfg.port;
            NEXT_TELEMETRY_DISABLED = "1";
          } // cfg.environment);
        };

        networking.firewall = mkIf cfg.openFirewall {
          allowedTCPPorts = [ cfg.port ];
        };
      };
    };
}
