# Usage

```
system-manager build --flake .#crawlspace
sudo $(which system-manager) switch --flake .#crawlspace
```
## Impure mode

```
system-manager build --flake .#crawlspace --nix-option show-trace 1 --nix-option pure-eval false
```
