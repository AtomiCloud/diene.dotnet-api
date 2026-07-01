#!/usr/bin/env bash
set -euo pipefail

# JetBrains InspectCode dead-code analysis via dn-inspect, run on the project SDK (net10).
# Runs both all-project and production-only passes.

RULE_FILTER="${DEAD_CODE_RULE_FILTER:-Unused|NeverInstantiated|NeverUsed|NotAccessed|NeverSubscribed|UnassignedField}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

print_summary() {
  local log_file="$1"

  awk '
    /^File[[:space:]]+Line[[:space:]]+Rule[[:space:]]+Message/ { printing = 1 }
    printing { print }
    printing && /Total:/ { found = 1; exit }
    END { exit found ? 0 : 1 }
  ' "${log_file}" && return

  echo "No issue summary was found; last 80 log lines:"
  tail -80 "${log_file}"
}

run_inspection() {
  local label="$1"
  shift

  local log_file
  log_file="$(mktemp -t dotnet-dead-code.XXXXXX.log)"

  echo "🔍 ${label}"
  if dn-inspect "$@" --filter "${RULE_FILTER}" >"${log_file}" 2>&1; then
    echo "✅ ${label}: no issues found"
    rm -f "${log_file}"
    return 0
  fi

  echo "❌ ${label}: issues found"
  print_summary "${log_file}"
  rm -f "${log_file}"
  return 1
}

echo "🔧 Restoring .NET tools (jb)..."
dotnet tool restore >/dev/null

failed=0

if ! run_inspection "Dead-code inspection: all projects" "${ROOT}/dotnet-base.slnx"; then
  failed=1
fi

if ! run_inspection "Dead-code inspection: production projects" \
  --projects "${ROOT}/App/App.csproj" "${ROOT}/Lib/Lib.csproj"; then
  failed=1
fi

exit "${failed}"
