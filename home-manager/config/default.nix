{
  imports = [
    ./center.nix

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