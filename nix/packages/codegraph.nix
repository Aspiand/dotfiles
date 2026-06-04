{ ... }:

let
  mkCodegraph =
    pkgs:
    pkgs.buildNpmPackage rec {
      pname = "codegraph";
      version = "0.9.6";

      src = pkgs.fetchFromGitHub {
        owner = "colbymchenry";
        repo = "codegraph";
        rev = "625e5663c439ca9c4dba4df95c5050d1dfc1a2c6";
        hash = "sha256-8dL83yxhDfSKWn12q8GMhonvPwPIUP9YVOZ9vDL6Les=";
      };

      npmDepsHash = "sha256-y9nlK+fVCDGhFqXNX4PLoj8D4Fo8s8WNQPAvxYyTE40=";

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
