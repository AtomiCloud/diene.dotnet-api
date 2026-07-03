#!/usr/bin/env bash
set -euo pipefail

# CI entry point: one suite with coverage + threshold. Usage: test.sh <unit|int>

MODE="${1:-}"
[ "${MODE}" != "unit" ] && [ "${MODE}" != "int" ] && echo "❌ Usage: test.sh <unit|int>" >&2 && exit 1

./scripts/ci/setup.sh

echo "🧪 Running ${MODE} tests with coverage..."
./scripts/local/dotnet-test.sh "${MODE}" --coverage

echo "✅ ${MODE} tests complete"
