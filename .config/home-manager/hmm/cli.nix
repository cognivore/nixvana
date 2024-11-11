{ pkgs, ... }:

{
  home.packages = [
    pkgs.mc
    pkgs.strace
    pkgs.darcs
    pkgs.passveil
    pkgs.gnupg
    pkgs.pinentry-curses
    pkgs.shmux
    pkgs.jq
    pkgs.gdu
  ];
}
