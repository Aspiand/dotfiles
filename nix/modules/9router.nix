{ ... }: {
  flake.nixosModules."9router" =
    { config, lib, pkgs, ... }:
    let
      cfg = config.services._9router;
      pname = "9router";
    in
    {
      options.services._9router = {
        enable = lib.mkEnableOption "9router — AI router and dashboard";

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.${pname};
          defaultText = lib.literalExpression "pkgs.${pname}";
          description = "9router package to use.";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Bind address for web UI and API.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 20128;
          description = "Port for web UI and API.";
        };

        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/9router";
          description = "Data directory for logs, sessions, and state.";
        };

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            OPENAI_API_KEY = "...";
            DATA_DIR = "/custom/path";
          };
          description = "Extra environment variables for 9router.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open port in firewall.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];

        systemd.tmpfiles.rules = [
          "d '${cfg.dataDir}' 0700 ${pname} ${pname} - -"
        ];

        users.users.${pname} = {
          isSystemUser = true;
          group = pname;
          home = cfg.dataDir;
          createHome = true;
        };
        users.groups.${pname} = { };

        systemd.services.${pname} = {
          description = "9router — AI router and dashboard";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            User = pname;
            Group = pname;
            WorkingDirectory = cfg.dataDir;
            ExecStart = lib.getExe cfg.package;
            Restart = "on-failure";
            RestartSec = 5;
            StateDirectory = pname;
            StateDirectoryMode = "0700";
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectHome = true;
            ProtectSystem = "strict";
          };

          environment = lib.recursiveUpdate {
            DATA_DIR = cfg.dataDir;
            HOST = cfg.host;
            PORT = toString cfg.port;
            NEXT_TELEMETRY_DISABLED = "1";
          } cfg.environment;
        };

        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPorts = [ cfg.port ];
        };
      };
    };
}
