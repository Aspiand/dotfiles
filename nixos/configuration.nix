{ config, pkgs, ... }:

# https://github.com/NixOS/nixpkgs/blob/b8ec4fd2a4edc4e30d02ba7b1a2cc1358f3db1d5/nixos/modules/services/x11/desktop-managers/gnome.nix#L329-L348
# https://nixos.org/manual/nixos/stable/#sec-gnome-without-the-apps

{
  nixpkgs.config.allowUnfree = true;
  security.rtkit.enable = true;
  time.timeZone = "Asia/Makassar";
  home-manager.backupFileExtension = "bak";
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  imports = [ ./hardware-configuration.nix ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };

  boot = {
    # kernelModules = [ "i915" ];
    # kernelParams = [ "i915.force_probe=46a8" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "aira";
    networkmanager.enable = true;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  users.users.ao = {
    isNormalUser = true;
    description = "Aspian";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    packages = with pkgs; [ ];
  };

  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
      # NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      # Games
      mangohud
      # protonup-qt
      lutris
      # bottles
      # heroic

      gparted
    ];

    gnome.excludePackages = with pkgs; [
      # orca
      # evince
      # file-roller
      geary
      # gnome-disk-utility
      # seahorse
      # sushi
      # sysprof
      #
      # gnome-shell-extensions
      #
      # adwaita-icon-theme
      # nixos-background-info
      # gnome-backgrounds
      # gnome-bluetooth
      # gnome-color-manager
      # gnome-control-center
      # gnome-shell-extensions
      gnome-tour # GNOME Shell detects the .desktop file on first log-in.
      gnome-user-docs
      # glib # for gsettings program
      # gnome-menus
      # gtk3.out # for gtk-launch program
      # xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
      # xdg-user-dirs-gtk # Used to create the default bookmarks
      #
      # baobab
      epiphany # Browser
      gnome-text-editor
      # gnome-calculator
      # gnome-calendar
      gnome-characters
      # gnome-clocks
      # gnome-console
      # gnome-contacts
      # gnome-font-viewer
      # gnome-logs
      gnome-maps
      gnome-music
      # gnome-system-monitor
      # gnome-weather
      # loupe
      # nautilus
      gnome-connections
      # simple-scan
      # snapshot
      # totem
      yelp
      # gnome-software
    ];
  };

  programs = {
    adb.enable = true;
    firefox.enable = true;
    steam.enable = true;
    steam.gamescopeSession.enable = true;
    gamemode.enable = true;
  };

  zramSwap = {
    enable = true;
    priority = 5;
    # memoryMax = ;
    algorithm = "zstd";
    swapDevices = 1;
    memoryPercent = 50;
  };

  services = {
    sysprof.enable = false;
    netdata.enable = false;
    printing.enable = false; # Enable CUPS to print documents.
    zerotierone.enable = true;

    udev.packages = [ pkgs.android-udev-rules ];

    openssh = {
      enable = false;
      ports = [ 22 ];
      settings = {
        UseDns = true;
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    xserver = {
      enable = true;
      # libinput.enable = true; # Enable touchpad support (enabled default in most desktopManager).

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      videoDrivers = [ "modesetting" ];

      xkb = {
        layout = "us";
        variant = "";
      };

      excludePackages = with pkgs; [ xterm ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ ... ];
  #   allowedUDPPorts = [ ... ];
  # };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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
}
