{ lib, ... }:

{
  programs = {
    git = {
      enable = true;
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

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        dark = true;
        navigate = true;
        line-numbers = true;
        side-by-side = false;
      };
    };
  };
}
