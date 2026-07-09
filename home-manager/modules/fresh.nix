{ config, pkgs, ... }:
{
  xdg.configFile."fresh/config.json".source = config.lib.file.mkOutOfStoreSymlink ../../.config/fresh/config.json;

  home.packages = with pkgs; [
    # Language Servers
    bash-language-server
    dockerfile-language-server
    gopls
    lua-language-server
    marksman
    nixd
    phpactor
    pyright
    yaml-language-server
    vscode-langservers-extracted # HTML, CSS, JSON, ESLint
  ];
}
