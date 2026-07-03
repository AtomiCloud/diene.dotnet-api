#!/usr/bin/env bash
set -euo pipefail

# JetBrains InspectCode (dn-inspect) dead-code passes: all projects, then production only.

RULE_FILTER="${DEAD_CODE_RULE_FILTER:-Unused|NeverInstantiated|NeverUsed|NotAccessed|NeverSubscribed|UnassignedField}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SOLUTION="$(find "${ROOT}" -maxdepth 1 -name '*.slnx' 2>/dev/null | head -1)"
SUMMARY_AWK='/^File[[:space:]]+Line[[:space:]]+Rule[[:space:]]+Message/{p=1} p{print} p&&/Total:/{f=1;exit} END{exit f?0:1}'

[ -z "${SOLUTION}" ] && echo "❌ No .slnx solution found in ${ROOT}" >&2 && exit 1

echo "🔧 Restoring .NET tools (jb)..."
dotnet tool restore >/dev/null

failed=0

echo "🔍 Dead-code inspection: all projects"
log="$(mktemp -t dotnet-dead-code.XXXXXX.log)"
if dn-inspect "${SOLUTION}" --filter "${RULE_FILTER}" >"${log}" 2>&1; then
  echo "✅ all projects: no issues found"
else
  failed=1
  echo "❌ all projects: issues found"
  if ! awk "${SUMMARY_AWK}" "${log}"; then
    echo "No issue summary was found; last 80 log lines:"
    tail -80 "${log}"
  fi
fi
rm -f "${log}"

echo "🔍 Dead-code inspection: production projects"
log="$(mktemp -t dotnet-dead-code.XXXXXX.log)"
if dn-inspect --projects "${ROOT}/App/App.csproj" "${ROOT}/Lib/Lib.csproj" --filter "${RULE_FILTER}" >"${log}" 2>&1; then
  echo "✅ production projects: no issues found"
else
  failed=1
  echo "❌ production projects: issues found"
  if ! awk "${SUMMARY_AWK}" "${log}"; then
    echo "No issue summary was found; last 80 log lines:"
    tail -80 "${log}"
  fi
fi
rm -f "${log}"

[ "${failed}" -ne 0 ] && exit 1

echo "✅ Dead-code inspection complete"
