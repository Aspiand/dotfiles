{ config, lib, pkgs, ... }:

{
  time.timeZone = "Asia/Makassar";
  system.stateVersion = "24.05";
  terminal.font = "${pkgs.nerd-fonts.caskaydia-cove}/share/fonts/truetype/NerdFonts/CaskaydiaCove/CaskaydiaCoveNerdFont-SemiBoldItalic.ttf";
  user.shell = "${pkgs.bashInteractive}/bin/bash";

  android-integration = {
    termux-setup-storage.enable = true;
    termux-wake-lock.enable = true;
    termux-wake-unlock.enable = true;
    termux-open-url.enable = true;
  };

  environment = {
    packages = [ pkgs.busybox ];
    etcBackupExtension = ".bak";
    motd = "Welcome!";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  home-manager = {
    backupFileExtension = "hm.bak";
    useGlobalPkgs = true;

    config = { config, lib, pkgs, ... }:
      {
        imports = [ ../home-manager/default.nix ];

        nixpkgs.config.allowUnfree = true;

        home = {
          stateVersion = "25.05";

          shellAliases = {
            more = "less";
            nodg = "nix-on-droid generations";
            nodr = "nix-on-droid rollback";
            nods = "nix-on-droid build switch --flake ~/.config/dotfiles/nix-on-droid";
          };

          packages = with pkgs; [
            php
            phpPackages.composer
            python312
          ];
        };

        programs = {
          bash.enable = true;
          clamav.enable = true;
          gpg.enable = true;
          yt-dlp.enable = true;
          yt-dlp.path = "/data/data/com.termux.nix/files/home/storage/Share/YouTube/";
        };

        services = {
          sshd = {
            enable = true;
            port = 3022;
            addressFamily = "inet";
            dir = "${config.home.homeDirectory}/.ssh";
          };

          gpg-agent = {
            enable = false;
            enableSshSupport = true;
            enableBashIntegration = true;
            pinentry.package = pkgs.pinentry-tty;
            defaultCacheTtl = 600;
            defaultCacheTtlSsh = 600;
          };
        };
      };
  };
}
