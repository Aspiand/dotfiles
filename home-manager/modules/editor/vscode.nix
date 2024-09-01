{ config, pkgs, lib, ... }:

with lib; let cfg = config.programs.utils.vscode; in

{
  options.programs.utils.vscode.enable = mkEnableOption "VSCodium";

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        waderyan.gitblame
        mhutchie.git-graph
        donjayamanne.githistory
        codezombiech.gitignore
        # felipecaputo.git-project-manager
      ];

      userSettings = {
        "files.autoSave" = "off";
        "workbench.startupEditor" = "none";
        "editor.minimap.renderCharacters" = false;

        "[nix]"."editor.tabSize" = 2;
        "[python]" = {
          "editor.tabSize" = 4;
          "editor.insertSpaces" = true;
        };
      };
    };

    home.file.".local/share/applications/vscode.desktop".text = ''
      [Desktop Entry]
      Name=VSCodium
      Comment=Free/Libre Open Source Software Binaries of VSCode
      Exec=${config.programs.vscode.package}
      Icon=codium
      Terminal=false
      Type=Application
      Categories=Development;IDE;
    '';
  };
}