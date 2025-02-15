#!/usr/bin/env bash

# Check that we don't have keys generated
if [ -f ~/.config/sops/age/keys.txt ]; then
  echo "Keys already generated. Exiting."
  exit 1
fi
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
