{ lib, config, pkgs, ... }:

with lib;

{
  options.programs.utils.librewolf.enable = mkEnableOption "librewolf";

  config = mkIf config.programs.utils.librewolf.enable {
    home.file.".local/share/applications/librewolf.desktop".text = ''
      [Desktop Entry]
      Actions=new-private-window;new-window;profile-manager-window
      Categories=Network;WebBrowser
      Exec=librewolf --name librewolf %U
      GenericName=Web Browser
      Icon=librewolf
      MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https
      Name=Librewolf
      StartupNotify=true
      StartupWMClass=librewolf
      Terminal=false
      Type=Application
      Version=1.4

      [Desktop Action new-private-window]
      Exec=librewolf --private-window %U
      Name=New Private Window

      [Desktop Action new-window]
      Exec=librewolf --new-window %U
      Name=New Window

      [Desktop Action profile-manager-window]
      Exec=librewolf --ProfileManager
      Name=Profile Manager
    '';

    programs.librewolf = {
      enable = true;
      settings = {
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;
        "browser.safebrowsing.blockedURIs.enabled" = true;
        "browser.safebrowsing.downloads.enabled" = true;
        "browser.sessionstore.resume_from_crash" = true;
        "browser.startup.restoreTabs" = true;

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