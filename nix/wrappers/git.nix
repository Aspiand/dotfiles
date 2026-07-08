{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.git = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.gitFull;

      env = rec {
        GIT_AUTHOR_NAME = "Aspian";
        GIT_AUTHOR_EMAIL = "muhammad.aspian.d@gmail.com";
        GIT_COMMITTER_NAME = GIT_AUTHOR_NAME;
        GIT_COMMITTER_EMAIL = GIT_AUTHOR_EMAIL;
        GIT_CONFIG_NOSYSTEM = "1";
      };

      runtimeInputs = with pkgs; [
        delta
        git
      ];

      preHook = ''
        export GIT_CONFIG_GLOBAL="${pkgs.writeText "gitconfig" ''
          [pull]
            rebase = true
          [init]
            defaultBranch = main
          [core]
            fileMode = true
          [delta]
            dark = true
            navigate = true
            line-numbers = true
            side-by-side = false
          [merge]
            conflictstyle = diff3
          [diff]
            colorMoved = default
          [rerere]
            enabled = true
        ''}"
      '';
    };
  };
}
