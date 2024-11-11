{ pkgs, ... }:

{

  # TODO: Use specialArgs! https://github.com/rengare/dotfiles/blob/979f1028aaae772a5bc9220ca86e0cd4574e5137/nix/linux/home.nix

  home.username = "sweater";
  home.homeDirectory = "/home/sweater";
  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = [ ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  stylix = {
    enable = true;
    image = ./wallpaper.png;
    fonts = {
      emoji =  {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      monospace = {
        package = pkgs.nerdfonts;
        name = "CaskaydiaCove NFM";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
    };
    polarity = "dark";
    targets = {
      i3.enable = true;
      gtk.enable = true;
      rofi.enable = true;
      xresources.enable = true;
      kitty = {
        enable = true;
        variant256Colors = true;
      };
    };
  };

  imports = [
    ./glpkgs.nix
    ./music.nix
    ./rofi.nix
    ./neovim.nix
    ./ergonomics.nix
    ./cli.nix
    ./gui.nix
    ./services.nix
    ./lsp.nix
  ];
}
