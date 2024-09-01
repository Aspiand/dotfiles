{ lib, config, pkgs, ... }:

with lib;

let cfg = config.programs.utils.librewolf; in

{
  options.programs.utils.librewolf.enable = mkEnableOption "librewolf";

  config = mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      settings = {
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;
        "browser.safebrowsing.blockedURIs.enabled" = true;
        "browser.safebrowsing.downloads.enabled" = true;
        "browser.sessionstore.resume_from_crash" = true;

        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.resistFingerprinting" = true;
        "privacy.resistFingerprinting.letterboxing" = true;

        "identity.fxaccounts.enabled" = false;

        "security.OCSP.require" = true;
      };
    };
  };
}