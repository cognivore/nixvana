{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, system-manager, ... }:

  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };

  in

  {
    systemConfigs."rethink" = system-manager.lib.makeSystemConfig {
      modules = [
        ./rethink
      ];
    };

    systemConfigs."crawlspace" = system-manager.lib.makeSystemConfig {
      modules = [
        ./crawlspace/system.nix
        ./monitoring/prometheus.nix
        ./databases/postgresql.nix
      ];
    };

    systemConfigs."urborg" = system-manager.lib.makeSystemConfig {
      modules = [
        ./urborg/system.nix
        ./monitoring/prometheus.nix
        ./databases/postgresql.nix
      ];
    };

    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [
        system-manager.packages.x86_64-linux.default
      ];
    };
  };
}
