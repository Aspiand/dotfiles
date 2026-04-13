{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.modern-utils;
in

{
  options.programs.modern-utils = {
    enable = mkEnableOption "Enable modern and better CLI utilities";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bat
      bottom
      duf
      fd
      gitui
      htop
      jq
      lnav
      lsof
      ncdu
      nix-tree
      ripgrep
      yq
    ];

    programs = {
      direnv = {
        enable = mkDefault false;
        nix-direnv.enable = true;
        enableBashIntegration = true;
      };

      eza = {
        enable = mkDefault true;
        git = true;
        icons = "always";
        enableBashIntegration = true;
        extraOptions = [
          "--git-repos"
          "--group"
          "--group-directories-first"
          "--mounts"
          "--no-quotes"
        ];
      };

      fzf = {
        enable = mkDefault true;
        enableBashIntegration = mkDefault true;
        tmux.enableShellIntegration = mkDefault true;
        defaultOptions = [
          "--border"
          "--height 100%"
          "--multi"
        ];
      };

      zoxide = {
        enable = mkDefault true;
        enableBashIntegration = true;
      };
    };
  };
}
