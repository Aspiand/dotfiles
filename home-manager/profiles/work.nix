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
      rustic-clean = "rustic forget --keep-none --prune";
    };

    packages = with pkgs; [
      s3fs
      rustic
      python312
      python312Packages.pip
      python312Packages.virtualenv

      distrobox
      duf
      gocryptfs
      nix-bash-completions
    ];
  };

  programs = {
    git.extraConfig.core.editor = "${pkgs.vscode}/bin/code --wait";

    bash.enable = true;
    tmux.enable = true;
    tmux.shell = "${pkgs.bash}/bin/bash";

    ssh = {
      matchBlocks.github.identityFile = [
        "~/.ssh/aspian_ed25519"
      ];
    };
  };
}
