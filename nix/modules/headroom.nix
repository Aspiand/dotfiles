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
      inherit (lib) mkIf mkOption mkRemovedOptionModule types;
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

        environment = mkOption {
          type = types.attrsOf types.str;
          default = { };
          example = {
            ORT_STRATEGY = "system";
            ORT_LIB_LOCATION = "/usr/lib/libonnxruntime.so";
            HF_HUB_OFFLINE = "1";
            HEADROOM_CACHE_DIR = "/var/cache/headroom";
          };
          description = "Environment variables for the headroom service.";
        };

        environmentFile = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
          example = [ "/run/secrets/headroom.env" ];
          description = ''
            Environment files loaded by systemd (EnvironmentFile=).
            Each file should contain KEY=value pairs, one per line.
          '';
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

        optimizationMode = mkOption {
          type = types.nullOr (types.enum [
            "token"
            "cache"
          ]);
          default = null;
          description = ''
            Headroom proxy optimization strategy (--mode).
            - token: max compression, rewrite prior turns for token savings
            - cache: freeze prior turns, stabilise prefix for KV cache hits
            - null:  don't pass --mode, use Headroom default
          '';
        };

        backend = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "anyllm";
          description = ''
            Upstream LLM backend (--backend).
            - anthropic: direct Anthropic API
            - litellm:   via LiteLLM
            - anyllm:    via any-llm provider
            - null: use Headroom default
          '';
        };

        budget = mkOption {
          type = types.nullOr types.float;
          default = null;
          example = 10.00;
          description = ''
            Daily budget limit in USD (--budget).
            null = no limit.
          '';
        };

        log = {
          destination = mkOption {
            type = types.str;
            default = "journald";
            example = "/var/log/headroom/headroom.jsonl";
            description = ''
              Where headroom sends logs.
              - "journald": no --log-file flag, systemd journal captures stdout/stderr
              - "stderr":   explicit --log-file /dev/stderr
              - <path>:     --log-file <path>, e.g. "/var/log/headroom/headroom.log"
            '';
          };

          level = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "info";
            description = ''
              Log verbosity (--log-level).
              Common values: debug, info, warn, error.
              null = don't pass flag, use Headroom default.
            '';
          };
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
                # Build optional flag pairs: [flag, value] or nothing
                optFlag = flag: value:
                  lib.optionals (value != null) [ flag (toString value) ];
              in
              lib.escapeShellArgs (
                [ baseCmd ]
                ++ modeArgs
                ++ optFlag "--backend" cfg.backend
                ++ optFlag "--mode" cfg.optimizationMode
                ++ optFlag "--budget" cfg.budget
                ++ optFlag "--log-level" cfg.log.level
                ++ lib.optionals (cfg.log.destination != "journald") [
                  "--log-file"
                  (if cfg.log.destination == "stderr" then "/dev/stderr" else cfg.log.destination)
                ]
                ++ cfg.extraArgs
              );

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
            EnvironmentFile = cfg.environmentFile;
          };

          environment = cfg.environment;
        };

        networking.firewall = mkIf (cfg.openFirewall && cfg.mode == "proxy") {
          allowedTCPPorts = [ cfg.port ];
        };
      };
    };
}
