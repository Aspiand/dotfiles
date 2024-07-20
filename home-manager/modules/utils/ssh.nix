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

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      controlMaster = mkIf cfg.control "auto";
      controlPersist = mkIf cfg.control "30m";
      controlPath = mkIf cfg.control "~/.ssh/control/%r@%n:%p";
    };
    # programs.ssh.addKeysToAgent = [];
  };
}