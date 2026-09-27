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
      env.GITHUB_PERSONAL_ACCESS_TOKEN = {
        file = config.sops.secrets."github-token".path;
      };
    };

    markitdown.command = "${pkgs.markitdown-mcp}/bin/markitdown-mcp";
    mempalace = {
      command = "${pkgs.mempalace}/bin/mempalace";
      args = [ "mcp" ];
    };
    nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
    fetch.command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
    victorialogs = {
      enable = false;
      command = "${pkgs.mcp-victorialogs}/bin/mcp-victorialogs";
      env = {
        VL_INSTANCE_ENTRYPOINT = "https://victorialogs.astrapia-kokanue.ts.net";
      };
    };
    victoriametrics = {
      enable = false;
      command = "${pkgs.mcp-victoriametrics}/bin/mcp-victoriametrics";
      env = {
        VM_INSTANCE_ENTRYPOINT = "https://victoriametrics.astrapia-kokanue.ts.net";
        VM_INSTANCE_TYPE = "single";
      };
    };
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

  sops.secrets = {
    "github-token" = {
      sopsFile = ../../secrets/common.yml;
    };
  };

}
