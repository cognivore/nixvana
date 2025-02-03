{ pkgs, config, lib, ... }:

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

  home.sessionVariables = {
    GTK_THEME = config.gtk.theme.name;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  stylix = {
    enable = true;
    autoEnable = true;
    image = ./touch-the-spirit-realm.jpg;
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
    ./local-glx-apps.nix
  ];
}
