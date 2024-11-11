{ pkgs, ... }:

{
  home.packages = [
    #######
    # Nix #
    #######

    # "nix.enableLanguageServer": true,
    # "nix.formatterPath": "nixfmt",
    # "nix.serverPath": "nixd",
    # "nix.serverSettings": {"nixd": {
    # "formatting": {
    #         "command": [
    #             "nixfmt"
    #         ]
    #     }
    # }

    pkgs.nixd
    pkgs.nixfmt-rfc-style
  ];
}
