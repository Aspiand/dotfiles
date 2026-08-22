/*
  https://github.com/NixOS/nix/issues/6536#issuecomment-1254858889
  Raw token from secrets/common.yml, key `github-token`.
  Rendered into a proper `access-tokens = github.com=...` line and
  pulled into /etc/nix/nix.conf at runtime
*/

{
  flake.nixosModules.github-token =
    { config, ... }:
    {
      config = {
        sops.secrets.github-token = {
          sopsFile = ../../secrets/common.yml;
          mode = "0440";
          group = config.users.groups.keys.name;
        };

        sops.templates.nix-access-tokens = {
          content = ''
            access-tokens = github.com=${config.sops.placeholder."github-token"}
          '';
          mode = "0440";
          group = config.users.groups.keys.name;
        };

        nix.extraOptions = ''
          !include ${config.sops.templates.nix-access-tokens.path}
        '';
      };
    };
}
