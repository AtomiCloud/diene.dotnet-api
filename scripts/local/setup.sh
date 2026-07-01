#!/usr/bin/env bash
set -euo pipefail

# Local repository setup. Pre-commit hooks are installed automatically by the Nix dev shell
# (shellHook); add project setup steps here. The CI counterpart (scripts/ci/setup.sh) delegates
# here so local and CI setup cannot drift.

echo "🔧 Restoring repo-local .NET tools (.config/dotnet-tools.json)..."
dotnet tool restore

echo "✅ Setup complete"
