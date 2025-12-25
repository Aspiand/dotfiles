# source: https://discourse.nixos.org/t/how-to-have-libgtk-4-media-gstreamer-on-nixos/37548/17

{pkgs, stdenv, fetchFromGitHub }:
{
  hanabi = stdenv.mkDerivation rec {
    pname = "gnome-ext-hanabi";
    version = "";
    dontBuild = false;
    nativeBuildInputs = with pkgs; [
      meson
      ninja
      glib
      nodejs
      wrapGAppsHook4
      appstream-glib
      gobject-introspection
#      makeWrapper
#      pkg-config
      shared-mime-info
    ];

    buildInputs = with pkgs; [
    # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    gst_all_1.gst-vaapi
#    gst_all_1.gst-plugins-rs
    clapper
    gjs
    gtk4
    glib
#    libadwaita
#    libGL
#    libsoup
    wayland
    wayland-protocols
    ];
    dontWrapGApps = true;

#    installPhase = ''
#      cp -r $out/share/gsettings-schemas/gnome-extension-hanabi-/glib-2.0 $out/share/glib-2.0
#    '';
    
    postPatch = ''
      patchShebangs build-aux/meson-postinstall.sh 
    '';

#    postInstall = ''
#      mv "$out/share/glib-2.0/schemas" "$out/share/gnome-shell/extensions/hanabi-extension@jeffshee.github.io/schemas"
#    '';

    postFixup = ''
      wrapGApp "$out/share/gnome-shell/extensions/hanabi-extension@jeffshee.github.io/renderer/renderer.js"
      ln -s "$out/share/gsettings-schemas/gnome-ext-hanabi-/glib-2.0/schemas" "$out/share/gnome-shell/extensions/hanabi-extension@jeffshee.github.io/schemas"

    '';

    src = fetchFromGitHub {
      owner = "rootacite";
      repo = "gnome-ext-hanabi-gnome49";
      rev = "10c0460b12bf0d6e42e50b9f0071201671059a70";
      sha256 = "sha256-O7C5CadzMtw6VwSOtMJ6R+C4sjl5GG1WZDF45Vay2oo=";
    };
  };
}

# git ls-remote https://github.com/jeffshee/gnome-ext-hanabi for rev