{ pkgs, ... }:

{
  home.packages = [
    pkgs.xorg.setxkbmap
    pkgs.xorg.xinput
    pkgs.xorg.xsetroot

    pkgs.xclip
    pkgs.autocutsel
  ];
}
