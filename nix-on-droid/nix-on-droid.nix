{ config, lib, pkgs, ... }:

{
  time.timeZone = "Asia/Makassar";
  system.stateVersion = "24.05";
  terminal.font = "${pkgs.nerd-fonts.caskaydia-cove}/share/fonts/truetype/NerdFonts/CaskaydiaCove/CaskaydiaCoveNerdFont-SemiBoldItalic.ttf";

  environment = {
    packages = [ pkgs.busybox ];
    etcBackupExtension = ".bak";
    motd = "Welcome!";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  user = {
    userName = "aka";
    shell = ${pkgs.bashInteractive}/bin/bash;
    uid = 1000;
    gid = 1000;
  };

  home-manager = {
    backupFileExtension = "hm.bak";
    useGlobalPkgs = true;

    config =
      { config, lib, pkgs, ... }:
      {
        nixpkgs.config.allowUnfree = true;
        shell.bash.enable = true;

        home = {
          stateVersion = "24.11";

          shellAliases = {
            more = "less";
            nodg = "nix-on-droid generations";
            nodr = "nix-on-droid rollback";
            nods = "nix-on-droid build switch";
          };

          packages = with pkgs; [
            php
            phpPackages.composer
            python312
          ];
        };

        programs = {
          clamav.enable = true;
          gpg.enable = true;
          yt-dlp.enable = true;
          yt-dlp.path = "/data/data/com.termux.nix/files/home/storage/Share/YouTube/";
        };

        services.sshd = {
          enable = true;
          port = 3022;
          addressFamily = "inet";
          dir = "${config.home.homeDirectory}/.ssh";
        };

        services.gpg-agent = {
          enable = false;
          enableSshSupport = true;
          enableBashIntegration = true;
          pinentryPackage = pkgs.pinentry-tty;
          defaultCacheTtl = 600;
          defaultCacheTtlSsh = 600;
        };
      };
  };
}
