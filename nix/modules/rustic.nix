{ ... }: {
  flake.customModules.rustic =
    { config, lib, pkgs, ... }:
    let
      inherit (lib) mkIf mkEnableOption mkOption filterAttrs mapAttrs' nameValuePair types;

      format = pkgs.formats.toml { };

      cfg = config.services.rustic;

      # Merge profile options into a TOML attrset.
      # `snapshot` key from settings → injected into `backup.snapshots` (array of tables).
      # `label` and `sources` come from profile options, not from settings.
      genProfileConfig = name: p:
        let
          label = if p.label == null then name else p.label;
          baseCfg = builtins.removeAttrs p.settings [ "snapshot" ];
          snapEntry = {
            inherit label;
            sources = p.sources;
          } // (builtins.removeAttrs (p.settings.snapshot or { }) [ "label" "sources" ]);
        in
        baseCfg // {
          backup = (baseCfg.backup or { }) // {
            snapshots = [ snapEntry ];
          };
        };

      # Resolve timer config: null → global default, {} → disabled, else → override.
      effectiveTimerConfig = p:
        if p.timerConfig == null then cfg.timerConfig
        else if p.timerConfig == { } then null
        else p.timerConfig;

      rusticBin = "${cfg.package}/bin/rustic";
      promFlag = if cfg.prometheus.enable then " --prometheus ${lib.escapeShellArg cfg.prometheus.address}" else "";
    in
    {
      options.services.rustic = {
        enable = mkEnableOption "rustic backup";

        package = mkOption {
          type = types.package;
          default = pkgs.rustic;
          defaultText = lib.literalExpression "pkgs.rustic";
          description = "rustic package to use.";
        };

        prometheus = {
          enable = mkEnableOption "prometheus metrics push to VictoriaMetrics";
          address = mkOption {
            type = types.str;
            default = "http://127.0.0.1:8428/api/v1/import/prometheus";
            description = "Prometheus remote write URL (VictoriaMetrics endpoint).";
          };
        };

        timerConfig = mkOption {
          type = types.nullOr (types.attrsOf types.anything);
          default = {
            OnCalendar = "daily";
            Persistent = true;
          };
          example = {
            OnCalendar = "0/4:00:00";
            Persistent = true;
          };
          description = ''
            Default systemd timer config. Used by profiles without their own timerConfig.
            Set profile's timerConfig to {} to disable timer (manual only).
          '';
        };

        backups = mkOption {
          type = types.attrsOf (types.submodule ({ name, ... }: {
            options = {
              enable = mkEnableOption "this backup profile";

              label = mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "services";
                description = "Snapshot label. Falls back to profile attribute name.";
              };

              sources = mkOption {
                type = types.listOf types.path;
                example = [ "/var/lib/9router" ];
                description = "Paths to back up.";
              };

              environmentFile = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = ''
                  Path to environment file with RUSTIC_REPOSITORY, RUSTIC_PASSWORD,
                  RUSTIC_REPOSITORY_OPTIONS_*. Usually a sops-decrypted dotenv file.
                '';
              };

              timerConfig = mkOption {
                type = types.nullOr (types.attrsOf types.anything);
                default = null;
                example = {
                  OnCalendar = "0/12:00:00";
                  Persistent = true;
                };
                description = ''
                  Override default timer config for this profile.
                  null = inherit global default, {} = disable timer.
                '';
              };

              # Free-form rustic TOML — each top-level key becomes a [section].
              # Use `snapshot = { ... }` for [[snapshot]] entries; sources auto-injected.
              settings = mkOption {
                type = types.attrsOf types.anything;
                default = { };
                example = {
                  global.check-index = true;
                  backup.skip-if-unchanged = true;
                  backup."exclude-if-present" = [ ".nobackup" ];
                  forget."keep-daily" = 14;
                  forget."keep-weekly" = 8;
                  forget."keep-monthly" = 24;
                  snapshot = { label = "services"; };
                };
                description = ''
                  Full rustic TOML config. Each top-level attr = TOML section.
                  Use `snapshot` for [[snapshot]] entries (sources auto-injected).
                '';
              };
            };
          }));
          default = { };
          description = "Attribute set of backup profiles. Key = profile name.";
        };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];

        environment.etc = mapAttrs' (name: p:
          nameValuePair "rustic/${name}.toml" {
            source = format.generate "rustic-${name}.toml" (genProfileConfig name p);
            mode = "0440";
          }
        ) (filterAttrs (_: p: p.enable) cfg.backups);

        systemd.services = mapAttrs' (name: p:
          nameValuePair "rustic-${name}" {
            description = "rustic backup — ${name}";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            partOf = [ "rustic.target" ];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${rusticBin} backup -P ${name}${promFlag}";
              EnvironmentFile = lib.mkIf (p.environmentFile != null) [ p.environmentFile ];
              Environment = [ "RUSTIC_CONFIG_DIR=/etc/rustic" ];
              NoNewPrivileges = true;
              CapabilityBoundingSet = [ "" ];
              AmbientCapabilities = [ "" ];
              ProtectSystem = "strict";
              ProtectHome = true;
              PrivateDevices = true;
              PrivateTmp = true;
              ProtectKernelTunables = true;
              ProtectKernelModules = true;
              ProtectControlGroups = true;
              RestrictRealtime = true;
              RestrictNamespaces = true;
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
              UMask = "0077";
            };
          }
        ) (filterAttrs (_: p: p.enable) cfg.backups);

        systemd.timers = mapAttrs' (name: p:
          let
            tCfg = effectiveTimerConfig p;
          in
          nameValuePair "rustic-${name}" {
            description = "rustic backup timer — ${name}";
            wantedBy = lib.optional (tCfg != null) "timers.target";
            timerConfig = tCfg;
          }
        ) (filterAttrs (_: p: p.enable && effectiveTimerConfig p != null) cfg.backups);

        systemd.targets.rustic = {
          description = "rustic backups";
          wants = map (n: "rustic-${n}.service") (builtins.attrNames (filterAttrs (_: p: p.enable) cfg.backups));
        };
      };
    };
}
