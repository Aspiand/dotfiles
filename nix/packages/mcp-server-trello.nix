{ ... }:

let
  mkMcpServerTrello =
    pkgs:
    let
      sources = import ../_sources/_default.nix { inherit pkgs; };
      pkg = sources.mcp-server-trello;
    in
    pkgs.stdenv.mkDerivation rec {
      pname = "mcp-server-trello";
      inherit (pkg) version src;

      sourceRoot = "package";

      nativeBuildInputs = [ pkgs.makeWrapper ];

      installPhase = ''
        mkdir -p $out/lib/node_modules/mcp-server-trello
        cp -r * $out/lib/node_modules/mcp-server-trello/
        mkdir -p $out/bin
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/mcp-server-trello \
          --add-flags "$out/lib/node_modules/mcp-server-trello/build/index.js"
      '';

      meta = with pkgs.lib; {
        description = "MCP server for Trello boards, powered by Bun";
        homepage = "https://github.com/delorenj/mcp-server-trello";
        license = licenses.mit;
        mainProgram = "mcp-server-trello";
        platforms = platforms.linux;
      };
    };
in
{
  flake.overlays.mcp-server-trello = final: _: {
    mcp-server-trello = mkMcpServerTrello final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.mcp-server-trello = mkMcpServerTrello pkgs;
    };
}
