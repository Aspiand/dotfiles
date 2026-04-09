{ config, pkgs, ... }:

# https://github.com/NixOS/nixpkgs/blob/b8ec4fd2a4edc4e30d02ba7b1a2cc1358f3db1d5/nixos/modules/services/x11/desktop-managers/gnome.nix#L329-L348
# https://nixos.org/manual/nixos/stable/#sec-gnome-without-the-apps

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  time.timeZone = "Asia/Makassar";
  nixpkgs.config.allowUnfree = true;
  security.rtkit.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt

      mesa
      libva
      vulkan-loader
    ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    tmp.useTmpfs = false;

    loader = {
      systemd-boot.enable = false;

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = false;
        device = "nodev";
      };

      grub2-theme = {
        enable = true;
        footer = true;
        theme = "vimix";
      };
    };
  };

  networking = {
    hostName = "aira";
    networkmanager.enable = true;
    firewall = {
      enable = true;

      allowedTCPPorts = [
        3003 # immich machine learning
        2121 # ftp
        3923 # copyparty
      ];

      allowedUDPPorts = [
        67 68 # DHCP
      ];

      allowedTCPPortRanges = [
        {
          from = 8000;
          to = 9000;
        }
      ];
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
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
    packages = with pkgs; [ ];
    extraGroups = [
      "dialout"
      "docker"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      btrfs-progs
      gparted
      system-config-printer
    ];

    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
      NIXOS_OZONE_WL = "1";
      LD_LIBRARY_PATH = "${pkgs.gamemode.lib}/lib";
    };
  };

  programs = {
    firefox.enable = true;
    gamemode.enable = true;
    gamescope.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      protontricks.enable = false;
      extraCompatPackages = with pkgs; [
        gamemode
      ];
    };

    kdeconnect = {
      enable = false;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
      ];
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  zramSwap = {
    enable = true;
    priority = 100;
    swapDevices = 1;
    memoryPercent = 50;
    algorithm = "zstd";
    memoryMax = (size: size * 1024 * 1024 * 1024) 4; # GB
  };

  services = {
    lact.enable = false;
    tailscale.enable = true;
    resolved.enable = false; # https://wiki.nixos.org/wiki/Tailscale#DNS
    # udev.packages = [ pkgs.android-udev-rules ]; # 'android-udev-rules' has been removed due to being superseded by built-in systemd uaccess rules.
    logind.settings.Login.HandleLidSwitchDocked = "ignore";

    openssh = {
      enable = false;
      ports = [ 22 ];
      settings = {
        UseDns = true;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    xserver = {
      enable = false;
      # libinput.enable = true; # Enable touchpad support (enabled default in most desktopManager).

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

    printing = {
      enable = true; # Enable CUPS to print documents.
      drivers = [ pkgs.gutenprint ];
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      daemon.settings = {
        # log-driver = "journald";
        # storage-driver = "overlay2";

        dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];

        registry-mirrors = [
          "https://ghcr.io"
          "https://docker.io"
        ];
      };
    };
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
}
