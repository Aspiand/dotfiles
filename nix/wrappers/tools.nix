{ inputs, ... }: {
  perSystem = { pkgs, ... }:
  let
    importModule = path: (import path { inherit inputs; }).perSystem { inherit pkgs; };
    git = importModule ./git.nix;
    bash = importModule ./bash.nix;
    tmux = importModule ./tmux.nix;
    fzf = importModule ./fzf.nix;
    eza = importModule ./eza.nix;
    bat = importModule ./bat.nix;
    starship = importModule ./starship.nix;
  in {
    packages.my-tools = pkgs.symlinkJoin {
      name = "my-tools-wrapped";
      paths = [
        git.packages.git
        bash.packages.mybash
        tmux.packages.tmux
        fzf.packages.fzf
        eza.packages.eza
        bat.packages.bat
        starship.packages.starship
        pkgs.zoxide
      ];
    };
  };
}
