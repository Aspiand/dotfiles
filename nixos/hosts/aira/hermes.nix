{ lib, pkgs, ... }:
let
  hermesPkg = if builtins.hasAttr "hermes-agent" pkgs then pkgs.hermes-agent else null;
  hermesBin =
    if hermesPkg != null then
      "${lib.getExe' hermesPkg "hermes"}"
    else
      "/run/current-system/sw/bin/hermes";
in
{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = "/var/lib/hermes";
    extraDependencyGroups = [ "messaging" ];

    container = {
      enable = true;
      image = "ubuntu:26.04";
      backend = "docker";
      hostUsers = [ "ao" ];
      extraVolumes = [
        "/home/ao/Kode:/host/Kode:rw"
        "/home/ao/.config/dotfiles:/host/dotfiles:rw"
      ];
    };

    configFile = /home/ao/backup-hermes/home/config.yaml;
    environmentFiles = [ "/home/ao/backup-hermes/home/.env" ];
  };

  systemd.services.hermes-gateway = {
    description = "Hermes Agent Gateway";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${hermesBin} gateway run";
      Restart = "always";
      RestartSec = 10;
      DynamicUser = true;
      WorkingDirectory = "/tmp";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
