{ ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sweater";
  home.homeDirectory = "/home/sweater";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = [
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  imports = [
    ../include/programming/purescript.nix
  ];
}
