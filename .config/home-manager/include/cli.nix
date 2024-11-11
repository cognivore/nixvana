{ pkgs, ... }:

{
  home.packages = [

    pkgs.tmux
    pkgs.git
    pkgs.gdu

    pkgs.mc
    pkgs.strace

    pkgs.darcs
    pkgs.parallel
    pkgs.passveil
    pkgs.shmux

    pkgs.jq
    pkgs.curl

    pkgs.fzf
    pkgs.fzf-obc
    pkgs.sysz
    pkgs.tmuxPlugins.tmux-fzf

    pkgs.gnupg
    pkgs.pinentry-curses

  ];
}
