{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.programs.mcp;
in

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
    markitdown.command = "${pkgs.markitdown-mcp}/bin/markitdown-mcp";
    mempalace = {
      command = "${pkgs.mempalace}/bin/mempalace";
      args = [ "mcp" ];
    };
    nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
    fetch.command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
    searxng = {
      command = "${pkgs.mcp-searxng}/bin/mcp-searxng";
      env.SEARXNG_URL = "https://searxng.astrapia-kokanue.ts.net";
    };
    victorialogs = {
      command = "${pkgs.mcp-victorialogs}/bin/mcp-victorialogs";
      env.VL_INSTANCE_ENTRYPOINT = "https://victorialogs.astrapia-kokanue.ts.net";
    };
    victoriametrics = {
      command = "${pkgs.mcp-victoriametrics}/bin/mcp-victoriametrics";
      env.VM_INSTANCE_ENTRYPOINT = "https://victoriametrics.astrapia-kokanue.ts.net";
      env.VM_INSTANCE_TYPE = "single";
    };
  };

  home.packages = mkIf cfg.enable (
    with pkgs;
    [
      codegraph
      markitdown-mcp
      mempalace
      mcp-nixos
      mcp-server-fetch
      mcp-victoriametrics
      mcp-searxng
      mcp-victorialogs
    ]
  );
}
