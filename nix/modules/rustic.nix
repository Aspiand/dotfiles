/*
  TODO:

  - handle backup overlap
*/

{ ... }: {
  flake.customModules.rustic =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        mkIf
        mkEnableOption
        mkOption
        filterAttrs
        mapAttrs'
        nameValuePair
        mapAttrsToList
        optionalString
        types
        ;

      format = pkgs.formats.toml { };

      cfg = config.services.rustic;

      # Resolve timer config: null → global default, else → override.
      effectiveTimerConfig = p: if p.timerConfig == null then cfg.timerConfig else p.timerConfig;

      enabled = filterAttrs (_: p: p.enable) cfg.backups;

      mkWrapper =
        name: p:
        let
          bin = pkgs.writeShellScriptBin "rustic-${name}" ''
            set -a
            ${optionalString (p.environmentFile != null) ". ${p.environmentFile}"}
            set +a
            export RUSTIC_CACHE_DIR=/var/cache/rustic
            exec ${cfg.package}/bin/rustic -P ${name} "$@"
          '';
          # Remap wrapper → rustic so clap's `_rustic` dispatch works.
          # Load rustic's own completion lazily (bash-completion only sources this file on first TAB).
          completion = pkgs.writeText "rustic-${name}.bash" ''
            _rustic_${name}() {
              if ! declare -F _rustic >/dev/null && [[ -f ${cfg.package}/share/bash-completion/completions/rustic.bash ]]; then
                . ${cfg.package}/share/bash-completion/completions/rustic.bash
              fi
              COMP_WORDS[0]=rustic
              _rustic rustic "$2" "$3"
            }
            complete -F _rustic_${name} -o nosort -o bashdefault -o default rustic-${name}
          '';
        in
        pkgs.runCommand "rustic-${name}" { } ''
          mkdir -p $out/bin $out/share/bash-completion/completions
          ln -s ${bin}/bin/rustic-${name} $out/bin/rustic-${name}
          ln -s ${completion} $out/share/bash-completion/completions/rustic-${name}.bash
        '';
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
          enable = mkEnableOption "rustic Prometheus metrics push";
          address = mkOption {
            type = types.str;
            description = "Prometheus remote write URL";
          };
          user = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Basic auth user (env RUSTIC_PROMETHEUS_USER).";
          };
        };

        timerConfig = mkOption {
          type = types.nullOr (types.attrsOf types.anything);
          default = {
            OnCalendar = "daily";
            Persistent = true;
          };
          description = ''
            Default systemd timer config, e.g. { OnCalendar = "0/4:00:00"; Persistent = true; }.
            Used by profiles without their own timerConfig.
          '';
        };

        backups = mkOption {
          type = types.attrsOf (
            types.submodule (
              { name, ... }: {
                options = {
                  enable = mkEnableOption "this backup profile";

                  environmentFile = mkOption {
                    type = types.nullOr types.path;
                    default = null;
                    description = "Path to environment file.";
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

                  settings = mkOption {
                    type = types.attrsOf types.anything;
                    default = { };
                    example = {
                      global.check-index = true;
                      backup.skip-if-unchanged = true;
                      backup."exclude-if-present" = [ ".nobackup" ];
                      backup.snapshots = [
                        {
                          label = "services";
                          sources = [ "/var/lib/9router" ];
                        }
                      ];
                      forget."keep-daily" = 14;
                      forget."keep-weekly" = 8;
                      forget."keep-monthly" = 24;
                    };
                    description = ''
                      Full rustic TOML config, written verbatim to /etc/rustic/<name>.toml.
                    '';
                  };
                };
              }
            )
          );
          default = { };
          description = "Attribute set of backup profiles. Key is profile name.";
        };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ] ++ mapAttrsToList mkWrapper enabled;

        environment.etc = mapAttrs' (
          name: p:
          nameValuePair "rustic/${name}.toml" {
            source = format.generate "rustic-${name}.toml" p.settings;
            mode = "0440";
          }
        ) enabled;

        systemd.services = mapAttrs' (
          name: p:
          nameValuePair "rustic-${name}" {
            description = "rustic backup — ${name}";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            partOf = [ "rustic.target" ];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${cfg.package}/bin/rustic backup -P ${name}";
              Environment = [
                "RUSTIC_CONFIG_DIR=/etc/rustic"
                "RUSTIC_CACHE_DIR=/var/cache/rustic"
              ]
              ++ lib.optionals cfg.prometheus.enable [ "RUSTIC_PROMETHEUS=${cfg.prometheus.address}" ]
              ++ lib.optional (
                cfg.prometheus.enable && cfg.prometheus.user != null
              ) "RUSTIC_PROMETHEUS_USER=${cfg.prometheus.user}";
              EnvironmentFile = lib.optional (p.environmentFile != null) p.environmentFile;
              ReadWritePaths = [ "/var/cache/rustic" ];
              CacheDirectory = "rustic";
              NoNewPrivileges = true;
              CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];
              AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];
              ProtectSystem = "strict";
              ProtectHome = true;
              PrivateDevices = true;
              PrivateTmp = false;
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

        systemd.timers = mapAttrs' (
          name: p:
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
          wants = map (n: "rustic-${n}.service") (
            builtins.attrNames (filterAttrs (_: p: p.enable) cfg.backups)
          );
        };
      };
    };
}
