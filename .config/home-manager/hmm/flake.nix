{
  description = "Home Manager configuration of sweater";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = { url = "github:nix-community/nixGL"; };
    stylix = { url = "github:danth/stylix"; };
    passveil = {
      url = "github:doma-engineering/passveil";
      # Ensure passveil uses the same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shmux = { url = "github:doma-engineering/shmux"; };
  };

  outputs = { nixpkgs, home-manager, nixgl, stylix, passveil, shmux, ... }:
    {
      homeConfigurations."sweater" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          config.allowUnfreePredicate = (_: true);
          overlays = [ 
	    nixgl.overlay
	    (final: prev: {
	      passveil = passveil.packages.${final.system}.default;
	      shmux = shmux.packages.${final.system}.default;
	    })
          ];
        };

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ stylix.homeManagerModules.stylix ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
