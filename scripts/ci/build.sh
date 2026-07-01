#!/usr/bin/env bash
set -euo pipefail

# Reproducible build entry point, shared by local tasks' CI counterpart and later CI.

echo "🔨 Building solution (Release)..."
dotnet build dotnet-base.slnx -c Release

echo "✅ Build complete"
