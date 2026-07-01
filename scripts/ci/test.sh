#!/usr/bin/env bash
set -euo pipefail

# CI entry point: run unit and integration tests (normal mode). Reuses the same local
# engine the Taskfile uses, so local and CI behaviour cannot drift.

echo "🧪 Running unit tests..."
./scripts/local/dotnet-test.sh unit

echo "🧪 Running integration tests..."
./scripts/local/dotnet-test.sh int

echo "✅ Tests complete"
