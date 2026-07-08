{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.fzf = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fzf;
      env.FZF_DEFAULT_OPTS = "--border --height 100% --multi";
    };
  };
}
