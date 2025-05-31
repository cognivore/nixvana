{ pkgs, ... }:

{
  home.packages = [

    pkgs.tmux
    pkgs.git
    pkgs.gdu

    pkgs.mc

    pkgs.darcs
    pkgs.parallel
    pkgs.expect
    pkgs.passveil
    pkgs.shmux
    pkgs.seedot

    pkgs.jq
    pkgs.curl

    pkgs.fzf
    pkgs.fzf-obc
    pkgs.sysz
    pkgs.tmuxPlugins.tmux-fzf

    pkgs.gnupg
    pkgs.pinentry-curses

    pkgs.util-linux

    pkgs.nvix

    pkgs.mosh
  ];
}
