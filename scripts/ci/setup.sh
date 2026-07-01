#!/usr/bin/env bash
set -euo pipefail

# CI setup entry point. Delegates to the local helper so CI and local setup share one source
# of truth (the Taskfile uses scripts/local/setup.sh directly, never this CI script).

exec ./scripts/local/setup.sh
