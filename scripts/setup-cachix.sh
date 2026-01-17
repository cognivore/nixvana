#!/usr/bin/env bash
set -euo pipefail

# Setup script for cachix binary cache on pentavus
# This configures nix.conf to use haskell.cachix.org

NIXCONF_DIR="$HOME/.config/nix"
NIXCONF="$NIXCONF_DIR/nix.conf"

mkdir -p "$NIXCONF_DIR"

# Check if substituters are already configured
if grep -q "haskell.cachix.org" "$NIXCONF" 2>/dev/null; then
    echo "Cachix already configured in $NIXCONF"
    exit 0
fi

# Add cachix configuration
cat >> "$NIXCONF" << 'EOF'

# Cachix binary cache for Haskell packages
extra-substituters = https://haskell.cachix.org
extra-trusted-public-keys = haskell.cachix.org-1:m2M2sVFTqOK5cuCy9NMKcTxKgoOgyAyC/8u1EXGgkF8=
EOF

echo "Cachix configured in $NIXCONF"
echo "You may need to restart the nix-daemon for changes to take effect."
