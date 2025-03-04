{
  nixpkgs.overlays = [
    (import ../nixpkgs/overlays/mov-cli-youtube-overlay.nix)
  ];
}