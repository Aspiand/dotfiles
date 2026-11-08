{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.hermes-lcm = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "hermes-lcm";
        version = "0.7.0";

        src = pkgs.fetchFromGitHub {
          owner = "stephenschoettler";
          repo = "hermes-lcm";
          tag = "v${version}";
          hash = "sha256-0D5htaT/Y7uhYfI0yV1L7tiPjGf4kOJDdTMsb96uvhk=";
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
