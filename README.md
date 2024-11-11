# Nixvana

A unified home-manager and system-manager configuration for all systems.

Inspired by [NixOS constructor](https://github.com/manpages/nixos-constructor) and modern multi-output flakes  used for system configurations.

Thanks to the way flakes work, we can have a unified configuration for all systems.
Evaluator for this unified configuration then will only evaluate the necessary parts for the target system.
