{ ... }:

let
  mkActualMcp =
    pkgs:
    pkgs.buildNpmPackage rec {
      pname = "actual-mcp";
      version = "1.11.3";

      src = pkgs.fetchFromGitHub {
        owner = "s-stefanov";
        repo = "actual-mcp";
        rev = "v${version}";
        hash = "sha256-Vr4X4kcXY6GOe1ylV1jeZeUoS1QwXWWTNDOgb8JJqJE=";
      };

      npmDepsHash = "sha256-Z24ZDuBzll3Fcsc00GoAMXbu58nDvExMm33Goe7G4Xo=";

      nativeBuildInputs = with pkgs; [
        python3
        pkg-config
      ];

      buildInputs = with pkgs; [
        sqlite
      ];

      # better-sqlite3 (transitive via @actual-app/api) must compile from source
      npmFlags = [ "--build-from-source" ];

      makeCacheWritable = true;

      meta = with pkgs.lib; {
        description = "MCP server for Actual Budget — bridge @actual-app/api to MCP protocol";
        homepage = "https://github.com/s-stefanov/actual-mcp";
        license = licenses.mit;
        mainProgram = "actual-mcp";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
in
{
  flake.overlays.actual-mcp = final: _: {
    actual-mcp = mkActualMcp final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.actual-mcp = mkActualMcp pkgs;
    };
}
