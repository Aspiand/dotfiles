{ ... }:
{
  flake.customModules.freebuff2api =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.freebuff2api;
      pname = "freebuff2api";
      inherit (lib) mkIf mkOption types;
    in
    {
      options.services.freebuff2api = {
        enable = lib.mkEnableOption "freebuff2api — OpenAI-compatible Freebuff proxy";

        package = mkOption {
          type = types.package;
          default = pkgs.${pname};
          defaultText = lib.literalExpression "pkgs.${pname}";
          description = "freebuff2api package to use.";
        };

        listenAddr = mkOption {
          type = types.str;
          default = "127.0.0.1:8080";
          description = "Proxy listen address.";
        };

        upstreamBaseUrl = mkOption {
          type = types.str;
          default = "https://codebuff.com";
          description = "Freebuff backend URL.";
        };

        rotationInterval = mkOption {
          type = types.str;
          default = "6h";
          description = "Auth token rotation interval.";
        };

        requestTimeout = mkOption {
          type = types.str;
          default = "15m";
          description = "Upstream request timeout.";
        };

        environmentFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            Path to an environment file (systemd EnvironmentFile format).
            Loaded at service start. Use for sensitive values:
              AUTH_TOKENS=***              API_KEYS=***              HTTP_PROXY=http://proxy:8080
            Non-sensitive config goes in extraEnvironment.
          '';
        };

        extraEnvironment = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = "Extra environment variables (non-sensitive).";
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
        };

        users.groups.${pname} = { };

        systemd.services.${pname} = {
          description = "freebuff2api — OpenAI-compatible Freebuff proxy";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            User = pname;
            Group = pname;
            ExecStart = lib.getExe cfg.package;
            Restart = "on-failure";
            RestartSec = 5;

            # Hardening
            NoNewPrivileges = true;
            LockPersonality = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
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

          environment = {
            LISTEN_ADDR = cfg.listenAddr;
            UPSTREAM_BASE_URL = cfg.upstreamBaseUrl;
            ROTATION_INTERVAL = cfg.rotationInterval;
            REQUEST_TIMEOUT = cfg.requestTimeout;
          } // cfg.extraEnvironment;
        };

        networking.firewall = mkIf cfg.openFirewall (
          let
            port = lib.toInt (builtins.elemAt (lib.splitString ":" cfg.listenAddr) 1);
          in
          {
            allowedTCPPorts = [ port ];
          }
        );
      };
    };
}
