{ ... }:

{
  boot.initrd.systemd.enable = true;

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "mode=755"
      "size=25%"
    ];
  };

  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;

  environment.persistence."/persist/system" = {
    hideMounts = true;

    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/var/lib/NetworkManager"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/random-seed"
      "/var/lib/systemd/timers"
      "/var/lib/tailscale"
      "/var/log"
    ];

    files = [
      "/etc/machine-id"
    ];
  };
}
