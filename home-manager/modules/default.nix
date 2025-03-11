{
  imports = [
    ./center.nix

    ./bash.nix
    ./zsh.nix
    ./starship.nix
    ./tmux.nix

    # CLI
    ./clamav.nix
    # ./mov.nix
    ./mycli.nix
    ./neovim.nix
    ./password-store.nix
    ./yt-dlp.nix

    ./sshd.nix

    # deprecated
    ./librewolf.nix
  ];
}