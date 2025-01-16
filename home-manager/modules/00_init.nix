{
  imports = [
    ./01_core.nix
    ./center.nix

    ./bash.nix
    ./zsh.nix
    ./starship.nix
    ./tmux.nix

    # CLI
    ./clamav.nix
    ./mycli.nix
    ./password-store.nix
    ./neovim.nix
    ./yt-dlp.nix

    ./sshd.nix

    ./librewolf.nix
  ];
}