{ config, pksg, ... }:

{
  programs.firefox = {
    enable = true;

    profiles = {
      aspian = {
        id = 10;
        isDefault = false;
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
      }
    };
  };
}