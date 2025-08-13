{ config, pkgs, ... }:

{
  imports = [ ../. ];

  fonts.fontconfig.enable = true;
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "yuki";
    homeDirectory = "/home/yuki";
    stateVersion = "25.05";

    shellAliases = {
      hmbs = "home-manager build switch --flake ~/dotfiles/home-manager --verbose";
    };

    packages = with pkgs; [
      restic
      rustic
      distrobox
      duf
      nix-bash-completions
    ];
  };

  programs = {
    git.extraConfig.core.editor = "${pkgs.micro}/bin/micro";

    bash.enable = true;
    tmux.enable = true;
  };
}
