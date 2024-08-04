{ config, pkgs, lib, ... }:

with lib; let cfg = config.utils.ssh; in

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
      home.activation.ssh_setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "$HOME/.ssh" ]; then
        find "$HOME/.ssh" -type d -not -perm "700" -exec chmod -v 700 {} \;
        find "$HOME/.ssh" -type f -not -perm "600" -exec chmod -v 600 {} \;
      fi
      '';
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