{
  description = "Nix-darwin system flake for sweater's mac book pro";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      hostName = "pentavus";
      configuration =
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.htop
            pkgs.direnv
            pkgs.nix-direnv
            home-manager.packages.${pkgs.system}.home-manager
          ];

          # direnv integration for every shell
          programs.direnv.enable = true;
          programs.direnv.nix-direnv.enable = true;

          nix.enable = false;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          services.openssh = {
            enable = true;
          };

          users.users.sweater = {
            home = "/Users/sweater";

            # Fetch the key bundle once at build time and ship it into /etc/ssh/nix_authorized_keys.d/sweater
            openssh.authorizedKeys.keyFiles = [
              (builtins.fetchurl {
                url = "https://github.com/cognivore.keys";
                sha256 = "sha256-06VyCIFVLTMQ/QYqvfzmZhPjLP74oY0S6eXnrX7howk=";
              })
            ];
          };

          networking.hostName = hostName;
          networking.computerName = hostName;
          networking.localHostName = hostName;

        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#sweaters-MacBook-Pro
      darwinConfigurations.${hostName} = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
        ];
      };
    };
}
