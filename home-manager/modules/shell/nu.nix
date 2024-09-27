{ config, pkgs, lib, ... }:

with lib; let cfg = config.shell.nu; in

{ # https://www.nushell.sh/
  options.shell.nu.enable = mkEnableOption "Nushell";

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;
    };

    programs.oh-my-posh.enableNushellIntegration = true;
  };
}