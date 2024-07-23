{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.editor.vscode;
in

{
  options.editor.vscode = {
    enable = mkEnableOption "VSCode";
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
      ];

      userSettings = {
        "files.autoSave" = "off";
        "[nix]"."editor.tabSize" = 2;
        "workbench.startupEditor" = "none";
      };
    };
  };
}
