{ config, pkgs, lib, ... }:

{
  # Configure cachix binary cache for haskell packages
  # This dramatically speeds up builds by reusing pre-built Haskell packages
  
  # Install cachix and age tools
  home.packages = [
    pkgs.cachix
    pkgs.age
  ];

  # Configure nix to use haskell.cachix.org as a substituter
  # Note: This requires the nix.conf to be user-writable or root trust
  # For macOS with nix-darwin, this may need additional configuration
  
  # Create a helper script for pushing to cachix with age-decrypted token
  home.file.".local/bin/cachix-push" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      # Path to the age-encrypted cachix token
      ENCRYPTED_TOKEN="$HOME/Github/nixvana/secrets/cachix-token.age"
      
      if [[ ! -f "$ENCRYPTED_TOKEN" ]]; then
        echo "Error: Encrypted token not found at $ENCRYPTED_TOKEN"
        exit 1
      fi
      
      # Decrypt the token using SSH key
      export CACHIX_AUTH_TOKEN=$(age -d -i ~/.ssh/id_ed25519 "$ENCRYPTED_TOKEN")
      
      # Push to haskell cache
      exec cachix push haskell "$@"
    '';
  };

  # Create a helper script for watching and pushing builds
  home.file.".local/bin/cachix-watch-push" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      # Path to the age-encrypted cachix token
      ENCRYPTED_TOKEN="$HOME/Github/nixvana/secrets/cachix-token.age"
      
      if [[ ! -f "$ENCRYPTED_TOKEN" ]]; then
        echo "Error: Encrypted token not found at $ENCRYPTED_TOKEN"
        exit 1
      fi
      
      # Decrypt the token using SSH key
      export CACHIX_AUTH_TOKEN=$(age -d -i ~/.ssh/id_ed25519 "$ENCRYPTED_TOKEN")
      
      # Watch and push to haskell cache
      exec cachix watch-exec haskell -- "$@"
    '';
  };

  # Ensure ~/.local/bin is in PATH
  home.sessionPath = [ "$HOME/.local/bin" ];
}
