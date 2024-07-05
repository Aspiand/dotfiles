{
  home.shellAliases = {
    sshd = "$(which sshd) -f ~/.ssh/sshd_config";
  };
  
  programs = {
    bash.historyControl = [  ];
    zsh.autosuggestion.enable = true;
  };
}