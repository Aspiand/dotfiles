{
  imports = [
    ./center.nix # remove later

    ./bash.nix
    ./zsh.nix
    ./starship.nix
    ./tmux.nix

    # CLI
    ./neovim.nix
    ./password-store.nix
    ./yt-dlp.nix

    # deprecated
    ./librewolf.nix
  ];
}