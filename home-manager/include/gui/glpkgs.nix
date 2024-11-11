{ config, pkgs, lib, ...}:
let
  ngl = import ./nixgl.nix {
    inherit pkgs;
    inherit lib;
    inherit config;
  };
  kittyW = (ngl.nixGLMesaWrap pkgs.kitty);
  alacrittyW = (ngl.nixGLMesaWrap pkgs.alacritty);
  gimpW = (ngl.nixGLMesaWrap pkgs.gimp);
in
{
  programs.kitty = {
    enable = true;
    package = kittyW;
    extraConfig = ''
      enable_audio_bell no
    '';
  };

  programs.alacritty = {
    enable = true;
    package = alacrittyW;
  };

  home.packages = [
    gimpW
  ];
}
