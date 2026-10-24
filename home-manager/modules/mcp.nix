{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs.mcp.servers = {
    codegraph = {
      command = "${pkgs.codegraph}/bin/codegraph";
      args = [
        "serve"
        "--mcp"
      ];
    };
    deepwiki.url = "https://mcp.deepwiki.com/mcp";
    github = {
      command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      args = [
        "stdio"
        "--read-only"
      ];
    };

    markitdown.command = "${pkgs.markitdown-mcp}/bin/markitdown-mcp";
    mempalace = {
      command = "${pkgs.mempalace}/bin/mempalace";
      args = [ "mcp" ];
    };
    nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
    fetch.command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
  };

  home.packages = with pkgs; [
    codegraph
    markitdown-mcp
    mempalace
    mcp-nixos
    mcp-server-fetch
    mcp-searxng
    mcp-victoriametrics
    mcp-victorialogs
  ];
}
