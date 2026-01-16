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

    # Demo presentation framework (lowPrio set in overlay to avoid GMP collision)
    pkgs.demo
    pkgs.demo-hint-env # GHC with packages needed by hint interpreter at runtime
    pkgs.demo-src # Source files for hint to compile from (avoids PAGE21 bug)
  ];

  # Set DEMO_SRC_PATH for hint to find demo source files
  # This is needed to avoid GHC's PAGE21 relocation bug on Apple Silicon
  home.sessionVariables = {
    DEMO_SRC_PATH = "${pkgs.demo-src}/src";
  };
}
