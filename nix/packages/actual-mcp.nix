# ---------------------------------------------------------------------------
# actual-mcp — Nix package for s-stefanov/actual-mcp (main branch)
#
# Using main branch (post-v1.11.3) instead of tagged release because:
# - @actual-app/api bumped to 26.5.0 (fixes out-of-sync-migrations natively)
# - Balance cutoff fix: getAccountBalance used Date.now(), excluding future
#   transactions. Now uses 2999-01-01.
# - Timezone fix: new Date(date).getMonth() was timezone-dependent (PST→Jan 31
#   for "2024-02-01"). Now uses string split.
# - transfer_id exposed in get-transactions output.
# - 3 extra migration files are built into @actual-app/api@26.5.0, so no
#   postInstall patch needed.
#
# WHEN TO GO BACK TO TAG:
#   When s-stefanov tags a release including these fixes (v1.12.0+).
#   Check: https://github.com/s-stefanov/actual-mcp/releases
# ---------------------------------------------------------------------------

{ ... }:

let
  mkActualMcp =
    pkgs:
    pkgs.buildNpmPackage rec {
      pname = "actual-mcp";
      version = "main";

      src = pkgs.fetchFromGitHub {
        owner = "s-stefanov";
        repo = "actual-mcp";
        rev = "24925803dff2dfb697cb6e53c06662ee66c94f01";
        hash = "sha256-f1ktuVyhPbH1XFl384V+verWSs0TAzOUhweGE24tmug=";
      };

      npmDepsHash = "sha256-/Nfw52YwlTftMbm+dVnx0CwoqLoJ4QyByUvrNrAphRI=";

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
