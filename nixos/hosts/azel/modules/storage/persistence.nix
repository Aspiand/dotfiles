{ ... }:

{
  fileSystems."/persist".neededForBoot = true;

  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/ssh"
      "/var/lib/nixos"
      "/var/lib/NetworkManager"
      "/var/lib/bluetooth"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
