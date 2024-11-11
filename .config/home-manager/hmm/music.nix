{ config, pkgs, lib, ...}:

{

  home.packages = [
    # All of this stuff is here only for the mopidy
    # But spotify playback is currently broken, so... Whatever.
    pkgs.gst_all_1.gstreamer
    pkgs.gst_all_1.gst-plugins-base
    pkgs.gst_all_1.gst-plugins-good
    pkgs.gst_all_1.gst-plugins-bad
    pkgs.gst_all_1.gst-plugins-ugly
    pkgs.gst_all_1.gst-libav
  ];

  programs.ncmpcpp.enable = true;

  # It was never meant to work. It's just too good to be true.
  # Jokes aside, spotify broke their shit, the fixes will probably land in nixpkgs within a year.
  # It requires forked rust gstreamer plugins and updated foss spotify wrapper library.
  services.mopidy = {
    enable = true;
    extensionPackages = [ pkgs.mopidy-spotify pkgs.mopidy-mpd pkgs.mopidy-mpris ];
    extraConfigFiles = [ ./mopidy/spotify.conf ];
    settings = {
      mpd = {
        enabled = true;
        hostname = "::";
      };
      http = {
        enabled = true;
        hostname = "::";
      };
      moped = {
        enabled = true;
      };
      audio = {
        mixer = "software";
        output = "autoaudiosink";
      };
    };
  };

}
