{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = false;
    package = pkgs.firefox-devedition-bin;

    policies = {
      AppAutoUpdate = false;
      DefaultDownloadDirectory = "\${home}/Downloads";
      DisableAppUpdate = true;
      DontCheckDefaultBrowser = true;
      HttpsOnlyMode = "force_enabled";
      ManualAppUpdateOnly = true;
      Permissions = {
        Camera = {
          Allow = [];
          Block = [];
          BlockNewRequests = true;
          Locked = false;
        };

        Microphone = {
          Allow = [];
          Block = [];
          BlockNewRequests = true;
          Locked = false;
        };

        Location = {
          Allow = [];
          Block = [];
          BlockNewRequests = true;
          Locked = false;
        };

        Notifications = {
          Allow = [];
          Block = [];
          BlockNewRequests = true;
          Locked = false;
        };

        Autoplay = {
          Allow = [];
          Block = [];
          BlockNewRequests = true;
          Locked = false;
        };
      };
      PopupBlocking = {
        Allow = [];
        Default = false;
        Locked = false;
      };
    };

    profiles = {
      aspian = {
        id = 10;
        isDefault = true;
        name = "Aspian";

        search = {
          default = "Google";
          order = [
            "Google"
            "DuckDuckGo"
          ];
          privateDefault = "DuckDuckGo";
        };
      };

      i2p = {
        id = 30;
        name = "I2P";
        isDefault = false;
      };
    };
  };
}