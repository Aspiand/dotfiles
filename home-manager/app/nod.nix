{ config, pkgs, ... }:

{
  imports = [
    ./shell/ts.nix
    ./shell/bash.nix
    ./shell/zsh.nix
    ./editor/neovim.nix
    ./core.nix
  ];

  home.packages = with pkgs; [
    apt
    # busybox
    dpkg
    nano
  ];

  home.file.".ssh/sshd_config".text = ''
    PrintMotd yes
    PasswordAuthentication no
    HostKey /data/data/com.termux.nix/files/home/.ssh/ssh_host_rsa_key
    Port 3022

  '';
}
