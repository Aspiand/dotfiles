# ---------------------------------------------------------------------------
# actual-mcp — Nix package for s-stefanov/actual-mcp (v1.11.3)
#
# WHY postInstall PATCH (adds 3 migration files):
#   @actual-app/api@26.3.0 (bundled) has 50 migrations.
#   Actual Budget server (v26.5+) has 53 — the 3 extra are fetched from
#   actualbudget/actual repo (tag v26.6.0) and added in postInstall.
#   Without these, loadBudget throws "out-of-sync-migrations".
#   Issue: https://github.com/s-stefanov/actual-mcp/issues/165
#
# WHY NOT BUMP @actual-app/api:
#   @actual-app/api@26.5.0+ restructured @types/ tree (loot-core paths removed).
#   Bumping causes TS build error in 4 source files:
#     src/core/data/fetch-rules.ts          — RuleEntity import
#     src/core/data/fetch-transactions.ts   — TransactionEntity import
#     src/tools/rules/create-rule/index.ts  — RuleEntity import
#     src/tools/rules/get-rules/index.ts    — RuleEntity import
#   No PR fixing this yet (as of 2026-06-14).
#
# WHEN TO REMOVE THIS PATCH:
#   When actual-mcp ships a version that bumps @actual-app/api itself
#   (i.e. package.json declares ^26.5.0 or higher AND types are fixed).
#   Check: grep '@actual-app/api' in actual-mcp/package.json on new releases.
#   Then: remove the fetchurl lines + postInstall, restore normal buildNpmPackage.
# ---------------------------------------------------------------------------

{ ... }:

let
  # Fetch 3 missing migration files from actualbudget/actual repo (tag v26.6.0).
  # fetchurl returns a store path — cp works directly.
  migration_1768872504000 = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/actualbudget/actual/v26.6.0/packages/loot-core/migrations/1768872504000_add_payee_locations.sql";
    sha256 = "ebaa4677d62abfd442be138d9cc8778d8fb64132a8ac653f8c3f03a19e9046b5";
  };
  migration_1769000000000 = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/actualbudget/actual/v26.6.0/packages/loot-core/migrations/1769000000000_add_custom_upcoming_length.sql";
    sha256 = "6868b2ff18e8df85daa317e58cb96e04600a2d215b42334f8681cf2d67e52591";
  };
  migration_1778510362740 = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/actualbudget/actual/v26.6.0/packages/loot-core/migrations/1778510362740_add_cleanup_groups_and_def.sql";
    sha256 = "b2501d91f82ff56ca1140968c437f1c75ad8bed66b336c0154425b62f2500755";
  };

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

      # Inject 3 missing migration files — cp from fetched store paths.
      postInstall = ''
        MIGDIR="$out/lib/node_modules/actual-mcp/node_modules/@actual-app/api/dist/migrations"
        cp ${migration_1768872504000} "$MIGDIR/1768872504000_add_payee_locations.sql"
        cp ${migration_1769000000000} "$MIGDIR/1769000000000_add_custom_upcoming_length.sql"
        cp ${migration_1778510362740} "$MIGDIR/1778510362740_add_cleanup_groups_and_def.sql"
      '';

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
