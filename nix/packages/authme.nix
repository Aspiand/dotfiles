/*
  AuthMe Reloaded — login/registration plugin for offline-mode Paper servers.

  The jar is copied into the server's plugins/ directory by
  nixos/modules/minecraft-server.nix. Bump `version` and `hash` together from
  https://github.com/AuthMe/AuthMeReloaded/releases (Paper asset).
*/
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      version = "6.0.1";
    in
    {
      packages.authme = pkgs.fetchurl {
        name = "AuthMe-${version}-Paper.jar";
        url = "https://github.com/AuthMe/AuthMeReloaded/releases/download/${version}/AuthMe-${version}-Paper.jar";
        hash = "sha256-dwQzXp5zpjTZ2SY0T3eJf0x094+CRTpZ9aoPjSciRQo=";
      };
    };
}
