#!/usr/bin/env bash
set -euo pipefail

# CI entry point: full coverage for unit and integration tests. Each run enforces its
# configured minimum and preserves the cobertura report (even on failure) for Codecov.
# An optional mode (unit|int) runs a single suite so CI can fan the two out into parallel
# jobs (the integration job also needs Docker); with no arg both run, matching the local
# `pls test:*:coverage` entry points. Usage: coverage.sh [unit|int]

MODE="${1:-all}"
case "${MODE}" in
unit | int | all) ;;
*)
  echo "❌ Unknown mode '${MODE}'. Usage: coverage.sh [unit|int]"
  exit 1
  ;;
esac

[[ ${MODE} == int ]] || {
  echo "🧪 Unit coverage..."
  ./scripts/local/dotnet-test.sh unit --coverage
}

[[ ${MODE} == unit ]] || {
  echo "🧪 Integration coverage..."
  ./scripts/local/dotnet-test.sh int --coverage
}

echo "✅ Coverage complete"
