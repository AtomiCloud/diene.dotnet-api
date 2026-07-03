#!/usr/bin/env bash
set -euo pipefail

./scripts/ci/setup.sh

echo "🔨 Building solution (Release)..."
dotnet build ./*.slnx -c Release

echo "✅ Build complete"
