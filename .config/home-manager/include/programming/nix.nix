{ pkgs, ... }:

{
  home.packages = [
    pkgs.nixfmt-rfc-style
    pkgs.nixd
];
}
