{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.programs.git.enable {
    programs.git = {
      settings = {
        pull.rebase = true;
        init.defaultBranch = "main";

        user = {
          name = "Aspian";
          email = "muhammad.aspian.d@gmail.com";
        };

        core.fileMode = lib.mkDefault true;
      };

      ignores = [
        "tmp/"
        "vendor/"
        "node_modules/"
        ".venv/"
        ".vscode/"
        "__pycache__/"
        "*.pyc"
      ];
    };

    programs.delta = {
      enable = lib.mkDefault true;
      enableGitIntegration = lib.mkDefault true;
      options = {
        dark = true;
        navigate = true;
        line-numbers = true;
        side-by-side = false;
      };
    };

  };
}
