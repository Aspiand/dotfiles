{ config, pkgs, ... }:

{
  imports = [
    ./app/nod.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;

  home = {
    stateVersion = "23.11";

    packages = with pkgs; [
      (writeShellScriptBin "ffm" (builtins.readFile ../sh/ffm.sh)) # https://discourse.nixos.org/t/link-scripts-to-bin-home-manager/41774
    ];
  };

  programs.home-manager.enable = true;
}