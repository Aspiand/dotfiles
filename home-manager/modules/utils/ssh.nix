{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.utils.ssh;
in

{
  options.utils.ssh = {
    enable = mkEnableOption "SSH";
    control = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.ssh.enable = true;
    })

    (mkIf cfg.control {
      programs.ssh = {
        controlMaster = "auto";
        controlPersist = "30m";
        controlPath = "~/.ssh/control/%r@%n:%p";
      };
    })
  ];
}