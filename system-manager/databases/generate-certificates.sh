#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="/etc/ssl/postgresql-nix"
CERT_FILE="$TARGET_DIR/selfsigned.crt"
KEY_FILE="$TARGET_DIR/selfsigned.key"

echo "Creating target directory: $TARGET_DIR"
sudo mkdir -p "$TARGET_DIR"
sudo chown "$(whoami):$(whoami)" "$TARGET_DIR"

echo "Generating self-signed certificate (valid for 10000 days)..."
openssl req -new -x509 -days 10000 -nodes \
  -out "$CERT_FILE" \
  -keyout "$KEY_FILE" \
  -subj "/CN=localhost"

sudo chown postgres:postgres /etc/ssl/postgresql-nix/selfsigned.key
sudo chmod 600 /etc/ssl/postgresql-nix/selfsigned.key

sudo chown postgres:postgres /etc/ssl/postgresql-nix/selfsigned.crt
sudo chmod 600 /etc/ssl/postgresql-nix/selfsigned.crt

echo "Certificate and key generated at:"
echo "  Certificate: $CERT_FILE"
echo "  Key:         $KEY_FILE"
