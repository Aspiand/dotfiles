{ config, pkgs, ... }:

{
  imports = [ ../. ];

  fonts.fontconfig.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home = {
    username = "pc";
    homeDirectory = "/home/pc";
    stateVersion = "25.05";

    shellAliases = {
      hmbs = "nix run home-manager -- build switch";
      hmg = "nix run home-manager -- generations";
      rclean = "rustic forget --keep-none --prune";
    };

    packages = with pkgs; [
      bun
      # s3fs
      # restic
      rustic
      python312
      # python312Packages.pip
      # python312Packages.virtualenv
      php82
      php82Packages.composer
      # postman
      mailpit

      distrobox
      duf
      gemini-cli
      gocryptfs
      hugo
      jq
      # obsidian
      nix-bash-completions
    ];
  };

  programs = {
    git.extraConfig.core.editor = "${pkgs.vscode}/bin/code --wait";

    bash.enable = true;
    mycli.enable = true;
    tmux.enable = true;
    tmux.shell = "${pkgs.bash}/bin/bash";
    yt-dlp.enable = true;

    ssh = {
      matchBlocks.github.identityFile = [
        "~/.ssh/aspian_ed25519"
      ];
    };
  };
}
