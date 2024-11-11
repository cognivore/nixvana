{ pkgs, ... }:

{
  home.packages = [
    pkgs.stalonetray
    pkgs.remmina
    pkgs.firefox-esr
  ];
}
