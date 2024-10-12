{ config, pkgs, lib, ... }:

with lib; let cfg = config.programs.utils.vscode; in

{
  options.programs.utils.vscode.enable = mkEnableOption "VSCodium";

  config = mkIf cfg.enable {
    home.file.".local/share/applications/codium.desktop".text = ''
      [Desktop Entry]
      Actions=new-empty-window
      Categories=Utility;TextEditor;Development;IDE
      Comment=Code Editing. Redefined.
      Exec=codium %F
      GenericName=Text Editor
      Icon=vscodium
      Keywords=vscode
      Name=VSCodium
      StartupNotify=true
      StartupWMClass=vscodium
      Type=Application
      Version=1.4

      [Desktop Action new-empty-window]
      Exec=codium --new-window %F
      Icon=vscodium
      Name=New Empty Window
    '';

    home.file.".local/share/applications/codium-url-handler.desktop".text = ''
      [Desktop Entry]
      Categories=Utility;TextEditor;Development;IDE
      Comment=Code Editing. Redefined.
      Exec=codium --open-url %U
      GenericName=Text Editor
      Icon=vscodium
      Keywords=vscode
      MimeType=x-scheme-handler/vscodium
      Name=VSCodium - URL Handler
      NoDisplay=true
      StartupNotify=true
      Type=Application
      Version=1.4
    '';

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
        "extensions.autoCheckUpdates" = false;
        "workbench.sideBar.location" = "right";
        "git.openRepositoryInParentFolders" = "always";

        "[nix]"."editor.tabSize" = 2;
        "[python]" = {
          "editor.tabSize" = 4;
          "editor.insertSpaces" = true;
        };
      };
    };
  };
}