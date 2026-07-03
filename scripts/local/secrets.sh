#!/usr/bin/env bash
set -euo pipefail

export INFISICAL_API_URL="https://secrets.atomi.cloud"

# Idempotent: only log in if we aren't already authenticated.
infisical user get token --silent >/dev/null 2>&1 && echo "✓ Infisical already logged in" && exit 0

echo "→ Logging into Infisical..."
infisical login

echo "✅ Infisical login complete"
