{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages.mcp-server-trello = pkgs.stdenv.mkDerivation rec {
        pname = "mcp-server-trello";
        version = "1.8.1";
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/@delorenj/mcp-server-trello/-/mcp-server-trello-${version}.tgz";
          hash = "sha256-a+SQmO9I01SK5zVzjieTx7mNpIMFx7JV6NQm5bHu3kc=";
        };
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
    };
}
