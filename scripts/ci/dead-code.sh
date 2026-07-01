#!/usr/bin/env bash
set -euo pipefail

# CI entry point: all-project and production-only dead-code inspection.

echo "🔍 Dead-code inspection..."
./scripts/local/dotnet-dead-code.sh

echo "✅ Dead-code inspection complete"
