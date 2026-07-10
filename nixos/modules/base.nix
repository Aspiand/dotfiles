{
  flake.nixosModules.base =
    { config, lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
      inherit (lib) mkDefault;
    in
    {
      sops.secrets.env = {
        sopsFile = ../../secrets/common.yml;
        mode = "0440";
        owner = "root";
        group = "users";
      };

      environment.extraInit = ''
        . /run/secrets/env
      '';

      time.timeZone = mkDefault "Asia/Makassar";
      nixpkgs.config.allowUnfree = true;

      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };

        settings = {
          auto-optimise-store = true;
          trusted-users = [ "@wheel" ];
          substituters = [
            "https://cache.nixos.org"
            "https://nix.aspian.my.id"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "github-ci-2:eUvIhhjHCO/kJVGcFNd/sNCGSx59tj1QAXmb477OO00="
          ];
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
        };
      };

      i18n = mkDefaults {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "id_ID.UTF-8";
          LC_IDENTIFICATION = "id_ID.UTF-8";
          LC_MEASUREMENT = "id_ID.UTF-8";
          LC_MONETARY = "id_ID.UTF-8";
          LC_NAME = "id_ID.UTF-8";
          LC_NUMERIC = "id_ID.UTF-8";
          LC_PAPER = "id_ID.UTF-8";
          LC_TELEPHONE = "id_ID.UTF-8";
          LC_TIME = "id_ID.UTF-8";
        };
      };
    };
}
