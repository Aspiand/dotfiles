{ ... }:

let
  mkCodegraph =
    pkgs:
    pkgs.buildNpmPackage rec {
      pname = "codegraph";
      version = "0.7.11";

      src = pkgs.fetchFromGitHub {
        owner = "colbymchenry";
        repo = "codegraph";
        rev = "2c1a314b84fd3633624f10f752163f9629c105e2";
        hash = "sha256-MgHnfiOyp7wqUXjT9EuIrQdoDp2iKM61DNl0rDWXf3E=";
      };

      npmDepsHash = "sha256-jAhUuU1JFCcrOakP+K9IEkQa16slqj05iAcurrzXu3U=";

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
  flake.lib.codegraph.mkPackage = mkCodegraph;

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
