{ config, pkgs, ... }:

{
  imports = [
    ./../../home-manager/app/shell/all.nix
    ./../../home-manager/app/editor/neovim.nix
    ./../../home-manager/app/core.nix

    ./reconfigure.nix
  ];

  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      apt
      dpkg
      nano
      ncurses
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