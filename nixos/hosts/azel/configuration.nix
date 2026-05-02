{ inputs, pkgs, ... }:

{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  system.stateVersion = "26.05";
  boot.kernelParams = [ "nohibernate" ];
  time.timeZone = "Asia/Makassar";
  nixpkgs.config.allowUnfree = true;

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
  };

  systemd = {
    user.services.niri-flake-polkit.enable = false;
    targets = {
      hibernate.enable = false;
      hybrid-sleep.enable = false;
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

  programs = {
    niri.enable = true;
    dank-material-shell.enable = true;
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.caskaydia-cove
    material-icons
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  services = {
    displayManager.dms-greeter = {
      enable = true;
      configHome = "/home/aka";
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
      compositor = {
        name = "niri";
        customConfig = ''
          hotkey-overlay {
              skip-at-startup
          }

          environment {
              DMS_RUN_GREETER "1"
          }

          gestures {
            hot-corners {
              off
            }
          }

          layout {
            background-color "#000000"
          }
        '';
      };
    };

    xserver.enable = false;

    dbus.enable = true;

    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;

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
      alacritty
    ];

    variables = {
      EDITOR = "micro";
      VISUAL = "micro";
      TERMINAL = "alacritty";

      DESKTOP_SESSION = "niri";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # DMS_HIDE_TRAYIDS "discord,spotify"
    };

    # TODO: keep?
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
    pam.services.login.enableGnomeKeyring = true;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  networking = {
    hostName = "azel";
    networkmanager.enable = true;
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
}
