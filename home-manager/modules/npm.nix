/*
  By default, 'npm install -g' fails as the Nix store is read-only.
  This redirects global installations to ~/.npm/global and adds the bin directory to PATH.
*/

{ config, ... }:
{
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.npm/global/bin"
    ];

    file.".npmrc".text = ''
      prefix=${config.home.homeDirectory}/.npm/global
    '';
  };
}
