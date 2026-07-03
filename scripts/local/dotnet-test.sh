#!/usr/bin/env bash
set -euo pipefail

# Usage: dotnet-test.sh <unit|int> [--watch|--coverage] — per-kind project, coverage
# filters and threshold come from .config/*.test.yaml (override with DOTNET_TEST_CONFIG).

KIND="${1:-}"
MODE="${2:-normal}"

[ "${KIND}" != "unit" ] && [ "${KIND}" != "int" ] && echo "❌ Usage: dotnet-test.sh <unit|int> [--watch|--coverage]" >&2 && exit 1
# Reject unknown modes so a typo like `--cov` cannot silently skip threshold enforcement.
[ "${MODE}" != "normal" ] && [ "${MODE}" != "--watch" ] && [ "${MODE}" != "--coverage" ] && echo "❌ Unknown mode '${MODE}'. Usage: dotnet-test.sh <unit|int> [--watch|--coverage]" >&2 && exit 1

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG="${DOTNET_TEST_CONFIG:-$(find "${ROOT}/.config" -maxdepth 1 -name '*.test.yaml' 2>/dev/null | head -1)}"
[ ! -f "${CONFIG:-/nonexistent}" ] && echo "❌ Test config not found (.config/*.test.yaml)" >&2 && exit 1
! command -v yq >/dev/null && echo "❌ yq is required to read ${CONFIG}" >&2 && exit 1

PROJECT_REL="$(yq -er ".coverage.${KIND}.project // \"\"" "${CONFIG}")"
COV_MIN="$(yq -er ".coverage.${KIND}.minimum // \"\"" "${CONFIG}")"
COV_INC="$(yq -er ".coverage.${KIND}.include // [] | join(\"%2c\")" "${CONFIG}")"
COV_EXC="$(yq -er ".coverage.${KIND}.exclude // [] | join(\"%2c\")" "${CONFIG}")"
RESULTS="${ROOT}/TestResults/${KIND}"
COV_OUT="${RESULTS}/coverage"
PROJECT="${ROOT}/${PROJECT_REL}"

[ -z "${PROJECT_REL}" ] && echo "❌ Missing .coverage.${KIND}.project in ${CONFIG}" >&2 && exit 1
[ -z "${COV_MIN}" ] && echo "❌ Missing .coverage.${KIND}.minimum in ${CONFIG}" >&2 && exit 1
[ -z "${COV_INC}" ] && echo "❌ Missing .coverage.${KIND}.include in ${CONFIG}" >&2 && exit 1
[[ ${PROJECT_REL} != *.csproj || ${PROJECT_REL} == /* || ${PROJECT_REL} == *..* || ! -f ${PROJECT} ]] && echo "❌ ${KIND} project '${PROJECT_REL}' must be a relative .csproj path" >&2 && exit 1
# Validate the threshold so the numeric compare cannot degrade to a string compare.
[[ ! ${COV_MIN} =~ ^[0-9]+$ || ${COV_MIN} -gt 100 ]] && echo "❌ ${KIND} coverage minimum '${COV_MIN}' must be an integer in [0,100]" >&2 && exit 1

[ "${MODE}" = "--watch" ] && echo "👀 Watching ${KIND} tests..." && exec dotnet watch --project "${PROJECT}" test

if [ "${MODE}" = "normal" ]; then
  echo "🧪 Running ${KIND} tests..."
  mkdir -p "${RESULTS}"
  set +e
  dotnet test "${PROJECT}" -c Release --logger "trx;LogFileName=${KIND}.trx" --results-directory "${RESULTS}"
  code=$?
  set -e
  echo "📦 Test results preserved in ${RESULTS}"
  exit "${code}"
fi

echo "🧪 Running ${KIND} tests with coverage (min ${COV_MIN}%)..."
rm -rf "${RESULTS}"
mkdir -p "${RESULTS}" "${COV_OUT}"

# Artifacts are preserved even on failure so a red run still feeds Codecov.
set +e
dotnet test "${PROJECT}" -c Release \
  --logger "trx;LogFileName=${KIND}.trx" \
  --results-directory "${RESULTS}" \
  /p:CollectCoverage=true \
  /p:CoverletOutput="${COV_OUT}/" \
  /p:CoverletOutputFormat=cobertura \
  /p:Threshold="${COV_MIN}" \
  /p:ThresholdType=line \
  /p:Include="${COV_INC}" \
  /p:Exclude="${COV_EXC}"
code=$?
set -e

report="${COV_OUT}/coverage.cobertura.xml"
[ -f "${report}" ] && echo "📦 Coverage report: ${report}"

[ "${code}" -ne 0 ] && echo "❌ ${KIND} tests or coverage failed (exit ${code})" >&2 && exit "${code}"
[ ! -f "${report}" ] && echo "❌ No coverage report produced" >&2 && exit 1

valid="$(grep -m1 -oE 'lines-valid="[0-9]+"' "${report}" | grep -oE '[0-9]+' || true)"
[ "${valid:-0}" -le 0 ] && echo "❌ Coverage measured 0 lines — check the ${KIND} coverage Include matches a built assembly" >&2 && exit 1

echo "✅ ${KIND} coverage meets the ${COV_MIN}% minimum"
