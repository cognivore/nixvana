{
  description = "Home Manager configuration of sweater";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
    };
    stylix = {
      url = "github:danth/stylix";
    };
    passveil = {
      url = "github:doma-engineering/passveil";
      # Ensure passveil uses the same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shmux = {
      url = "github:doma-engineering/shmux";
    };
    purescript-overlay.url = "github:thomashoneyman/purescript-overlay";
    nvix.url = "github:niksingh710/nvix";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      system-manager,
      passveil,
      shmux,
      purescript-overlay,
      stylix,
      nixgl,
      nvix,
      sops-nix,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        config.allowUnfreePredicate = (_: true);
        overlays = [
          nixgl.overlay
          purescript-overlay.overlays.default
          (final: prev: {
            passveil = passveil.packages.${final.system}.default;
            shmux = shmux.packages.${final.system}.default;
            system-manager = system-manager.packages.${final.system}.system-manager;
            nvix = nvix.packages.${final.system}.full;
            sops-nix = sops-nix.homeManagerModules.sops;
          })
        ];
      };
    in
    {
      # Build this configuration using:
      #   home-manager switch --flake .#crawlspace
      # Or to build without activating:
      #   home-manager build --flake .#crawlspace

      homeConfigurations."crawlspace" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        extraSpecialArgs = {
          hostname = "crawlspace";
          # TODO: myShell isn't doing anything yet
          myShell = pkgs.zsh;
        };
        modules = [
          ./general.nix
          stylix.homeManagerModules.stylix
          ./crawlspace/home.nix
        ];
      };

      homeConfigurations."timetwister" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          hostname = "timetwister";
          # TODO: myShell isn't doing anything yet
          myShell = pkgs.zsh;
        };
        modules = [
          ./general.nix
          stylix.homeManagerModules.stylix
          ./timetwister/home.nix
        ];
      };


      homeConfigurations."nosnoop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          hostname = "nosnoop";
          # TODO: myShell isn't doing anything yet
          myShell = pkgs.zsh;
        };
        modules = [
          ./general.nix
          ./nosnoop/home.nix
        ];
      };
    };
}
