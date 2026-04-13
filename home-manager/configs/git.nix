{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = lib.mkDefault true;
    settings = {
      pull.rebase = true;
      init.defaultBranch = "main";

      user = {
        name = "Aspian";
        email = "muhammad.aspian.d@gmail.com";
      };

      core = {
        fileMode = lib.mkDefault true;
        pager = "${pkgs.delta}/bin/delta";
      };

      delta = {
        enable = true;
        dark = true;
        navigate = true;
        line-numbers = true;
        side-by-side = false;
      };

      interactive = {
        diffFilter = lib.mkIf config.programs.git.settings.delta.enable "${pkgs.delta}/bin/delta --color-only";
      };
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
}
