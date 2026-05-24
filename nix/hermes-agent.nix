{ ... }: {
  flake.nixosModules.hermes-agent = { config, lib, pkgs, ... }:
  let
    inherit (lib) mkIf mkEnableOption;
    cfg = config.services.hermes-agent;

    hermesPkg = if builtins.hasAttr "hermes-agent" pkgs then pkgs.hermes-agent else null;
    hermesBin = if hermesPkg != null
      then "${lib.getExe' hermesPkg "hermes"}"
      else "/run/current-system/sw/bin/hermes";
  in
  {
    options.services.hermes-agent = {
      gateway.enable = mkEnableOption "Hermes messaging gateway user service";
    };

    config = mkIf cfg.gateway.enable {
      systemd.user.services.hermes-gateway = {
        description = "Hermes Agent Gateway (user service)";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${hermesBin} gateway run";
          Restart = "always";
          RestartSec = 10;
        };
        wantedBy = [ "default.target" ];
      };
    };
  };
}
