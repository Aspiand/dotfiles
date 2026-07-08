{ inputs, ... }: {
  perSystem = { pkgs, ... }:
  let
    bashrc = pkgs.writeText "bashrc" ''
      shopt -s histappend autocd

      # Aliases
      alias reload='source ~/.bashrc'
      alias ls='eza --git --icons=always --git-repos --group --group-directories-first --no-quotes'
      alias ll='ls -la'
      alias cat='bat --paging=never'
      alias grep='rg'
      alias find='fd'
      alias jq='yq'

      # Starship prompt
      eval "$(starship init bash)"

      # Zoxide
      eval "$(zoxide init bash)"

      # FZF
      source <(fzf --bash)
    '';
  in {
    packages.mybash = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.bash;
      runtimeInputs = with pkgs; [ eza bat ripgrep fd starship zoxide fzf yq ];
      env = {
        HISTCONTROL = "ignoreboth";
        EDITOR = "micro";
        BASH_ENV = bashrc;
      };
      flags."--rcfile" = bashrc;
    };
  };
}
