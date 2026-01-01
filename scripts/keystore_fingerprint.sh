#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 /path/to/keystore alias"
  exit 2
fi
KEYSTORE=$1
ALIAS=$2
keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" | sed -n '/SHA256:/p'
