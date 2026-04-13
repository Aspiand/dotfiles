{ pkgs, ... }:

{
  system.stateVersion = "26.05";
  boot.kernelParams = [ "nohibernate" ];
  time.timeZone = "Asia/Makassar";

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
  };

  systemd.targets = {
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  services = {
    xserver.enable = false;
    dbus.enable = true; # TODO: fungsinya

    tailscale.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  users.users.aka = {
    isNormalUser = true;
    description = "Aspian";
    initialPassword = "nixos";
    shell = pkgs.bash;
    extraGroups = [
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      btrfs-progs
      cryptsetup
      git
      gparted
      micro
      tmux
    ];

    variables = {
      EDITOR = "micro";
      VISUAL = "micro";
    };

    # TODO: keep
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    persistence."/persist/system" = {
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
  };

  fileSystems."/persist".neededForBoot = true;

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;

      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
    };

    tmp.useTmpfs = false;
    supportedFilesystems = [ "btrfs" ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "id_ID.UTF-8";
      LC_IDENTIFICATION = "id_ID.UTF-8";
      LC_MEASUREMENT = "id_ID.UTF-8";
      LC_MONETARY = "id_ID.UTF-8";
      LC_NAME = "id_ID.UTF-8";
      LC_NUMERIC = "id_ID.UTF-8";
      LC_PAPER = "id_ID.UTF-8";
      LC_TELEPHONE = "id_ID.UTF-8";
      LC_TIME = "id_ID.UTF-8";
    };
  };

  networking = {
    hostName = "azel";
    networkmanager.enable = true;
  };
}
