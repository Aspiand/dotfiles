{ pkgs, ... }:

{
  programs.mcp.servers = {
    codegraph = {
      command = "${pkgs.codegraph}/bin/codegraph";
      args = [ "serve" "--mcp" ];
    };
    deepwiki.url = "https://mcp.deepwiki.com/mcp";
    markitdown.command = "${pkgs.markitdown-mcp}/bin/markitdown-mcp";
    mempalace = {
      command = "${pkgs.mempalace}/bin/mempalace";
      args = [ "mcp" ];
    };
    nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
    searxng = {
      command = "${pkgs.mcp-searxng}/bin/mcp-searxng";
      env.SEARXNG_URL = "https://searxng.nova.astrapia-kokanue.ts.net";
    };
  };
}
