{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.bat = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.bat;
      env.BAT_THEME = "TwoDark";
      flags."--style" = "numbers,changes,header";
    };
  };
}
