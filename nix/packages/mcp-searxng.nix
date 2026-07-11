{ ... }:

let
  mkMcpSearxng =
    pkgs:
    pkgs.stdenv.mkDerivation rec {
      pname = "mcp-searxng";
      version = "1.11.0";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/mcp-searxng/-/mcp-searxng-${version}.tgz";
        hash = "sha256-7HsgXllmjOzwGTGVWVwX8nTG5YWOHxmq9H2tL3HiTJA=";
      };

      sourceRoot = "package";

      nativeBuildInputs = [ pkgs.makeWrapper ];

      installPhase = ''
        mkdir -p $out/lib/node_modules/mcp-searxng
        cp -r * $out/lib/node_modules/mcp-searxng/
        mkdir -p $out/bin
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/mcp-searxng \
          --add-flags "$out/lib/node_modules/mcp-searxng/dist/index.js"
      '';

      meta = with pkgs.lib; {
        description = "MCP server for SearXNG metasearch engine";
        homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
        license = licenses.mit;
        mainProgram = "mcp-searxng";
        platforms = platforms.linux;
      };
    };
in
{
  flake.overlays.mcp-searxng = final: _: {
    mcp-searxng = mkMcpSearxng final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.mcp-searxng = mkMcpSearxng pkgs;
    };
}
