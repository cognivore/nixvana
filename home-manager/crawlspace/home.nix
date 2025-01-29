{ pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sweater";
  home.homeDirectory = "/home/sweater";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = [
    pkgs.remmina
  ];

  home.file =
    {
    };

  home.sessionVariables =
    {
    };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  stylix = {
    enable = true;
    image = ./wallpaper.png;
    fonts = {
      emoji = {
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

  programs.bash.shellAliases = {
    vim = "nvim";
  };

  programs.zsh.shellAliases = {
    vim = "nvim";
  };

  imports = [
    ../include/programming/purescript.nix
    ../include/gui/glpkgs.nix
    ../include/gui/rofi.nix
    ../include/gui.nix
    ./grafana.nix
    ./shells.nix
  ];
}
