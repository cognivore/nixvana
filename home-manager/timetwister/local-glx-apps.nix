{ config, pkgs, lib, ...}:
let
  ngl = import ../include/gui/nixgl.nix {
    inherit pkgs;
    inherit lib;
    inherit config;
  };
  firefoxW = (ngl.nixGLMesaWrap pkgs.firefox);
in
{
  home.packages = [
    firefoxW
  ];
}
