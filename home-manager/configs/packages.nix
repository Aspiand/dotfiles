{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Archive
    gnutar
    gzip
    unzip
    xz
    zip

    # Network
    aria2
    curl
    sshfs
    wget

    # Base Utils
    coreutils
    rsync
    trash-cli
  ];
}
