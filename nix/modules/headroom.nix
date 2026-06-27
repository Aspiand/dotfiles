# TODO: persistent directory for downloaded ai model or pre download on nix

{ ... }: {
  flake.customModules.headroom =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.headroom;
      inherit (lib) mkIf mkOption types;
    in
    {
      options.services.headroom = {
        enable = lib.mkEnableOption "headroom — context optimization layer for LLM applications";

        mode = mkOption {
          type = types.enum [
            "proxy"
            "mcp"
          ];
          default = "proxy";
          description = ''
            Headroom operation mode.
            - proxy: daemonised proxy server at listenAddress:port
            - mcp:   MCP server on stdio (for hermes-agent integration)
          '';
        };

        package = mkOption {
          type = types.package;
          default = pkgs.headroom;
          defaultText = lib.literalExpression "pkgs.headroom";
          description = "Headroom package to use.";
        };

        port = mkOption {
          type = types.port;
          default = 8787;
          description = "Port for proxy mode.";
        };

        listenAddress = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listen address for proxy mode.";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = "Open port in firewall for proxy mode.";
        };

        extraEnv = mkOption {
          type = types.attrsOf types.str;
          default = { };
          example = {
            ORT_STRATEGY = "system";
            ORT_LIB_LOCATION = "/usr/lib/libonnxruntime.so";
            HF_HUB_OFFLINE = "1";
          };
          description = "Extra environment variables for the service.";
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [
            "--log-level"
            "info"
          ];
          description = "Extra CLI arguments passed to headroom.";
        };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];

        systemd.services.headroom = {
          description = "headroom — context optimization for LLM applications";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            DynamicUser = true;

            ExecStart =
              let
                baseCmd = lib.getExe cfg.package;
                modeArgs =
                  if cfg.mode == "proxy" then
                    [
                      "proxy"
                      "--host"
                      cfg.listenAddress
                      "--port"
                      (toString cfg.port)
                    ]
                  else
                    [
                      "mcp"
                      "serve"
                    ];
              in
              lib.escapeShellArgs ([ baseCmd ] ++ modeArgs ++ cfg.extraArgs);

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
          };

          environment = cfg.extraEnv;
        };

        networking.firewall = mkIf (cfg.openFirewall && cfg.mode == "proxy") {
          allowedTCPPorts = [ cfg.port ];
        };
      };
    };
}
