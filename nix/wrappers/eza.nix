{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.eza = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.eza;
      flags = {
        "--git" = true;
        "--icons" = "always";
        "--git-repos" = true;
        "--group" = true;
        "--group-directories-first" = true;
        "--no-quotes" = true;
      };
    };
  };
}
