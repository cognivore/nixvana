#!/usr/bin/env bash
user="$1"                              
tmp=$(mktemp)
curl -fsSL "https://github.com/${user}.keys" -o "$tmp"
nix hash file "$tmp"                         
