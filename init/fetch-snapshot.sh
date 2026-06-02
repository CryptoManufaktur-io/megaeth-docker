#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f /private/artifact-bucket-key.json ]]; then
    echo "Could not find /private/artifact-bucket-key.json required file"
    exit 1
fi
