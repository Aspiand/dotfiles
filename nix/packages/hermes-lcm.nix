{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.hermes-lcm = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "hermes-lcm";
        version = "0.20.0";

        src = pkgs.fetchFromGitHub {
          owner = "stephenschoettler";
          repo = "hermes-lcm";
          tag = "v${version}";
          hash = "sha256-yJ1Nn+su7YbKd+cgVOizXChzLbKHqTprSprF1p9/HYk=";
        };

        dontBuild = true;
        installPhase = "cp -r . $out";

        passthru = {
          category = "hermes-plugin";
          pluginName = "hermes-lcm";
        };

        meta = with pkgs.lib; {
          description = "Lossless Context Management — Hermes plugin with a DAG-based context engine";
          homepage = "https://github.com/stephenschoettler/hermes-lcm";
          license = licenses.mit;
          platforms = platforms.all;
        };
      };
    };
}
