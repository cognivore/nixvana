# Usage

```
system-manager build --flake .#crawlspace
sudo $(which system-manager) switch --flake .#crawlspace
```

# Note

If you're enabling pgsql, please make sure to run `./databases/generate-certificates.sh` before switching system config.
