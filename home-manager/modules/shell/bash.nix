{ config, pkgs, lib, ... }:

with lib; let cfg = config.shell.bash; in

{
  options.shell.bash = {
    enable = mkEnableOption "Bash Shell";
    nix-path = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh";
      example = "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh";
    };
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historyFile = "${config.home.homeDirectory}/.local/history/bash";
      shellAliases.reload = "source ~/.bashrc";
    };
  };
}