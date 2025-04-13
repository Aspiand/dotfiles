{ config, pkgs, ... }:

# https://github.com/NixOS/nixpkgs/blob/b8ec4fd2a4edc4e30d02ba7b1a2cc1358f3db1d5/nixos/modules/services/x11/desktop-managers/gnome.nix#L329-L348
# https://nixos.org/manual/nixos/stable/#sec-gnome-without-the-apps

{
  imports = [ ./hardware-configuration.nix ];
  nixpkgs.config.allowUnfree = true;
  security.rtkit.enable = true;
  time.timeZone = "Asia/Makassar";
  home-manager.backupFileExtension = ".bak";
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  hardware.graphics.enable = true;

  boot = {
    kernelModules = [ "i915" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "aira";
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  users.users.ao = {
    isNormalUser = true;
    description = "Aspian";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  environment.systemPackages = with pkgs; [
    # # Games
    # mangohud
    # protonup-qt
    lutris
    # bottles
    # heroic
  ];

  programs = {
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
    printing.enable = true; # Enable CUPS to print documents.
    zerotierone.enable = true;

    xserver = {
      enable = true;
      # libinput.enable = true; # Enable touchpad support (enabled default in most desktopManager).

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      xkb = {
        layout = "us";
        variant = "";
      };
    };

    pulseaudio.enable = false;
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
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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