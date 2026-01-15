{
  description = "Home-Manager configuration for sweater";

  inputs = {
    nixpkgs.url              = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url         = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    system-manager.url       = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url                = "github:nix-community/nixGL";
    stylix.url               = "github:danth/stylix";
    purescript-overlay.url   = "github:thomashoneyman/purescript-overlay";

    passveil.url             = "github:doma-engineering/passveil";
    shmux.url                = "github:doma-engineering/shmux";
    seedot.url               = "github:cognivore/seedot";
    nvix.url                 = "github:niksingh710/nvix";
    demo.url                 = "github:cognivore/demo";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, stylix
                   , passveil, shmux, seedot, system-manager
                   , purescript-overlay, nixgl, nvix, demo, ... }:

  let
    #──────────── helper: pkgs with overlays for a given system ────────────
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nixgl.overlay
          purescript-overlay.overlays.default
          # our own overlay – no optionalAttrs / no final.system
          (final: prev: {
            passveil       = passveil.packages.${system}.default;
            shmux          = shmux.packages.${system}.default;
            seedot         = seedot.packages.${system}.default;
            nvix           = nvix.packages.${system}.core;
            system-manager = system-manager.packages.${system}.system-manager;
            # Use lowPrio to avoid libgmpxx collision with passveil
            demo           = prev.lib.lowPrio (demo.packages.${system}.demo);
            demo-hint-env  = prev.lib.lowPrio (demo.packages.${system}.hintEnv);
          })
        ];
      };

    pkgsLinux  = mkPkgs "x86_64-linux";
    pkgsDarwin = mkPkgs "aarch64-darwin";

    #──────────── helper: construct one HM config ──────────────────────────
    mkHM = { hostname, modules, pkgs }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit hostname; myShell = pkgs.zsh; };
        inherit modules;
      };
  in
  {
    homeConfigurations = {
      crawlspace = mkHM {
        hostname = "crawlspace";
        pkgs     = pkgsLinux;
        modules  = [
          ./general.nix
          stylix.homeManagerModules.stylix
          ./crawlspace/home.nix
        ];
      };

      timetwister = mkHM {
        hostname = "timetwister";
        pkgs     = pkgsLinux;
        modules  = [
          ./general.nix
          stylix.homeManagerModules.stylix
          ./timetwister/home.nix
        ];
      };

      nosnoop = mkHM {
        hostname = "nosnoop";
        pkgs     = pkgsLinux;
        modules  = [
          ./general.nix
          ./nosnoop/home.nix
        ];
      };

      urborg = mkHM {
        hostname = "urborg";
        pkgs     = pkgsLinux;
        modules  = [
          ./general11.nix
          ./urborg/home.nix
        ];
      };

      pentavus = mkHM {
        hostname = "pentavus";
        pkgs     = pkgsDarwin;
        modules  = [
          ./general11-darwin.nix
          ./pentavus/home.nix
        ];
      };
    };
  };
}
