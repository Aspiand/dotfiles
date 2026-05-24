{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = "/var/lib/hermes";
    extraDependencyGroups = [ "messaging" ];

    container = {
      enable = true;
      image = "ubuntu:26.04";
      backend = "docker";
      hostUsers = [ "ao" ];
      extraVolumes = [
        "/home/ao/Kode:/host/Kode:rw"
        "/home/ao/.config/dotfiles:/host/dotfiles:rw"
      ];
    };

    configFile = /home/ao/backup-hermes/home/config.yaml;
    environmentFiles = [ "/home/ao/backup-hermes/home/.env" ];
  };
}
