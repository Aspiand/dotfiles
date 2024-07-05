{ config, pkgs, ... }:

{
  imports = [
    ./../../home-manager/app/shell/ts.nix
    ./../../home-manager/app/shell/bash.nix
    ./../../home-manager/app/shell/zsh.nix
    ./../../home-manager/app/editor/neovim.nix
    ./../../home-manager/app/core.nix
  ];

  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      apt
      # busybox
      dpkg
      nano
    ];

    file = {
      ".ssh/sshd_config".text = ''
        Port 3022
        PrintMotd yes
        PasswordAuthentication no
        HostKey /data/data/com.termux.nix/files/home/.ssh/ssh_host_rsa_key
      '';
    };
  };
}