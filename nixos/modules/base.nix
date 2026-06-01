{
  flake.nixosModules.base =
    { lib, pkgs, ... }:
    {

      config = lib.mkDefault {
        time.timeZone = "Asia/Makassar";
        nixpkgs.config.allowUnfree = true;

        networking.networkmanager.enable = true;

        nix = {
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };

          settings = {
            auto-optimise-store = true;
            trusted-users = [ "@wheel" ];
            experimental-features = [
              "nix-command"
              "flakes"
              "pipe-operators"
            ];
          };
        };

        zramSwap = {
          enable = true;
          algorithm = "zstd";
          memoryPercent = 50;
          priority = 100;
        };

        i18n = {
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
    };
}
