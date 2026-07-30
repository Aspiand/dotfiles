{ ... }:

let
  mkN8nMcp =
    pkgs:
    pkgs.buildNpmPackage rec {
      pname = "n8n-mcp";
      version = "2.67.1";

      src = pkgs.fetchFromGitHub {
        owner = "czlonkowski";
        repo = "n8n-mcp";
        rev = "v${version}";
        hash = "sha256-h+wokO/SwSMM5Dwrx1zXyFvkN29SgZkdu4Ughbyxi4g=";
      };

      npmDepsHash = "sha256-oaK52l4qB7SVmRiRar016WksC63G+JZZ0VRh4/I+gRc=";
      npmDepsFetcherVersion = 2;

      nativeBuildInputs = with pkgs; [
        python3
        pkg-config
        makeWrapper
      ];

      buildInputs = with pkgs; [ sqlite ];

      # better-sqlite3 (optional) needs native compilation
      makeCacheWritable = true;
      npmBuildScript = "build";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/node_modules/n8n-mcp
        cp -r dist node_modules package.json $out/lib/node_modules/n8n-mcp/

        # Ship pre-built node DB and data files
        cp -r n8n-nodes.db data $out/lib/node_modules/n8n-mcp/ 2>/dev/null || true

        mkdir -p $out/bin
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/n8n-mcp \
          --add-flags "$out/lib/node_modules/n8n-mcp/dist/mcp/stdio-wrapper.js"

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "MCP server for n8n — AI-powered workflow automation with full node documentation, templates, and n8n API management";
        homepage = "https://github.com/czlonkowski/n8n-mcp";
        license = licenses.mit;
        mainProgram = "n8n-mcp";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
in
{
  flake.overlays.n8n-mcp = final: _: {
    n8n-mcp = mkN8nMcp final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.n8n-mcp = mkN8nMcp pkgs;
    };
}
