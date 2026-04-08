{ pkgs, ... }:

{
  system.stateVersion = "26.05";

  networking = {
    hostName = "azel";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Makassar";

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

  fileSystems."/persist".neededForBoot = true;

  services = {
    xserver.enable = false;
    dbus.enable = true;
    displayManager.defaultSession = "hyprland";

    greetd = {
      enable = true;
      settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  hardware.graphics.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    dconf.enable = true;
    fish.enable = true;
  };

  users.users.aka = {
    isNormalUser = true;
    description = "Aspian";
    initialPassword = "nixos";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      btrfs-progs
      cryptsetup
      git
      helix
      home-manager
      vim
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };

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

  fonts.packages = with pkgs; [
    material-symbols
    nerd-fonts.caskaydia-cove
    rubik
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}
