{ ... }:

let
  mkCodegraph =
    pkgs:
    pkgs.buildNpmPackage rec {
      pname = "codegraph";
      version = "1.4.1";

      src = pkgs.fetchFromGitHub {
        owner = "colbymchenry";
        repo = "codegraph";
        rev = "v1.4.1";
        hash = "sha256-bZtzBHLbqFqY7vxWqxqKFbBtOZRnTMO/loXcVGPkwgc=";
      };

      npmDepsHash = "sha256-HVd/0c0i0g+TjPE7hCXe2GPgbTwMb3nBoepTa3Dbkvo=";

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
    codegraph = mkCodegraph final;
  };

  perSystem =
    { pkgs, ... }:
    let
      codegraph = mkCodegraph pkgs;
    in
    {
      packages = {
        inherit codegraph;
      };
    };
}
