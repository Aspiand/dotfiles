/*
  Hindsight memory provider plugin for Hermes Agent.

  Lifted out of nix/packages/hindsight.nix when that file tracked
  numtide/llm-agents.nix. Upstream does not ship this plugin, so it stays local.

  It is a plain copy of `hindsight-integrations/hermes` from the hindsight repo,
  same `src` as the API package (identical hash, so no extra fetch).
*/
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.hindsight-hermes-plugin = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "hindsight-hermes-plugin";
        version = "1.1.0";

        src = pkgs.fetchFromGitHub {
          owner = "vectorize-io";
          repo = "hindsight";
          tag = "v${version}";
          hash = "sha256-0+BuUhlf3mljlo9F9cVLcnOORZhMlK1mFY7Cqem6oYs=";
        };

        dontBuild = true;
        installPhase = "cp -r hindsight-integrations/hermes $out";

        passthru = {
          category = "hermes-plugin";
          pluginName = "hindsight";
        };

        meta = with pkgs.lib; {
          description = "Hindsight memory provider plugin for Hermes Agent";
          homepage = "https://github.com/vectorize-io/hindsight/tree/main/hindsight-integrations/hermes";
          license = licenses.mit;
          platforms = platforms.all;
        };
      };
    };
}
