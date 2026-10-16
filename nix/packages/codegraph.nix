{ ... }:

let
  mkPackage =
    pkgs:
    pkgs.buildNpmPackage rec {
      pname = "codegraph";
      version = "1.6.2";

      src = pkgs.fetchFromGitHub {
        owner = "colbymchenry";
        repo = "codegraph";
        rev = "v1.6.2";
        hash = "sha256-G/rBBP1dk1JB17Y4+xubUlPd3iDU2oKLuoiaxZh6Lnw=";
      };

      npmDepsHash = "sha256-J8viY38M/loCoJmpxEOIApN6cpf6sU2aa80knVNRSvI=";

      nativeBuildInputs = with pkgs; [
        python3
        pkg-config
      ];

      buildInputs = with pkgs; [
        sqlite
      ];

      # better-sqlite3 needs to be built from source
      npmFlags = [ "--build-from-source" ];

      makeCacheWritable = true;

      meta = with pkgs.lib; {
        description = "Pre-indexed code knowledge graph for AI agents";
        homepage = "https://github.com/colbymchenry/codegraph";
        license = licenses.mit;
        mainProgram = "codegraph";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
in
{
  flake.overlays.codegraph = final: _: {
    codegraph = mkPackage final;
  };

  perSystem =
    { pkgs, ... }:
    let
      codegraph = mkPackage pkgs;
    in
    {
      packages = {
        inherit codegraph;
      };
    };
}
