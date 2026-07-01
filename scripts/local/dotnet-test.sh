#!/usr/bin/env bash
set -euo pipefail

# Run unit or integration tests on the project SDK.
# Modes: normal (default), --watch (dev/watch), --coverage (full coverage + threshold).
# Per-kind config (project, coverage include/exclude, threshold) lives in
# .config/dotnet-base.test.yaml (override with DOTNET_TEST_CONFIG).
# Coverage and test-result artifacts are preserved even when tests fail, so a red run
# still feeds Codecov. Usage: dotnet-test.sh <unit|int> [--watch|--coverage]

KIND="${1:-}"
MODE="${2:-normal}"

[[ ${KIND} == "unit" || ${KIND} == "int" ]] || {
  echo "❌ Usage: dotnet-test.sh <unit|int> [--watch|--coverage]"
  exit 1
}

# Reject unknown modes instead of silently falling through to normal tests — a typo like
# `--cov` must not quietly skip coverage/threshold enforcement.
case "${MODE}" in
normal | --watch | --coverage) ;;
*)
  echo "❌ Unknown mode '${MODE}'. Usage: dotnet-test.sh <unit|int> [--watch|--coverage]"
  exit 1
  ;;
esac

# Read the per-kind config straight from the YAML (unit and int share the same shape).
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG="${DOTNET_TEST_CONFIG:-${ROOT}/.config/dotnet-base.test.yaml}"
[[ -f ${CONFIG} ]] || {
  echo "❌ Test config not found: ${CONFIG}"
  exit 1
}
command -v yq >/dev/null || {
  echo "❌ yq is required to read ${CONFIG}"
  exit 1
}
yaml() { yq -er "${1} // \"\"" "${CONFIG}"; }
yaml_list() { yq -er "${1} // [] | join(\"%2c\")" "${CONFIG}"; }

PROJECT_REL="$(yaml ".coverage.${KIND}.project")"
COV_MIN="$(yaml ".coverage.${KIND}.minimum")"
COV_INC="$(yaml_list ".coverage.${KIND}.include")"
COV_EXC="$(yaml_list ".coverage.${KIND}.exclude")"
RESULTS="${ROOT}/TestResults/${KIND}"
COV_OUT="${RESULTS}/coverage"
PROJECT="${ROOT}/${PROJECT_REL}"

# Fail loudly on missing required config rather than running with empty paths/projects.
for key in PROJECT_REL COV_MIN COV_INC; do
  [[ -n ${!key} ]] || {
    echo "❌ Missing .coverage.${KIND} config for ${key} in ${CONFIG}"
    exit 1
  }
done

[[ ${PROJECT_REL} == *.csproj && ${PROJECT_REL} != /* && ${PROJECT_REL} != *..* && -f ${PROJECT} ]] || {
  echo "❌ ${KIND} project '${PROJECT_REL}' must be a relative .csproj path"
  exit 1
}

# Validate the threshold so the awk numeric compare can't silently degrade to a string
# compare (e.g. '100x' would always pass).
[[ ${COV_MIN} =~ ^[0-9]+$ && ${COV_MIN} -ge 0 && ${COV_MIN} -le 100 ]] || {
  echo "❌ ${KIND} coverage minimum '${COV_MIN}' must be an integer in [0,100]"
  exit 1
}

# Dev/watch mode hands off to `dotnet watch test` and never returns.
[[ ${MODE} == "--watch" ]] && {
  echo "👀 Watching ${KIND} tests..."
  exec dotnet watch --project "${PROJECT}" test
}

# Normal mode: run tests, always keep the trx result, propagate the test exit code.
[[ ${MODE} == "--coverage" ]] || {
  echo "🧪 Running ${KIND} tests..."
  mkdir -p "${RESULTS}"
  set +e
  dotnet test "${PROJECT}" -c Release --logger "trx;LogFileName=${KIND}.trx" --results-directory "${RESULTS}"
  code=$?
  set -e
  echo "📦 Test results preserved in ${RESULTS}"
  exit "${code}"
}

# Coverage mode: coverlet.msbuild writes directly to the Codecov path and enforces threshold.
echo "🧪 Running ${KIND} tests with coverage (min ${COV_MIN}%)..."
rm -rf "${RESULTS}"
mkdir -p "${RESULTS}" "${COV_OUT}"

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
[[ -f ${report} ]] && echo "📦 Coverage report: ${report}"

[[ ${code} -eq 0 ]] || {
  echo "❌ ${KIND} tests or coverage failed (exit ${code})"
  exit "${code}"
}

[[ -f ${report} ]] || {
  echo "❌ No coverage report produced"
  exit 1
}

valid="$(grep -m1 -oE 'lines-valid="[0-9]+"' "${report}" | grep -oE '[0-9]+')"
[[ ${valid:-0} -gt 0 ]] || {
  echo "❌ Coverage measured 0 lines — check the ${KIND} coverage Include matches a built assembly"
  exit 1
}
echo "✅ ${KIND} coverage meets the ${COV_MIN}% minimum"
