# https://github.com/notusknot/dotfiles-nix

{
  imports = [
    ./editor
    ./shell
    ./services
    ./utils
  ];
}