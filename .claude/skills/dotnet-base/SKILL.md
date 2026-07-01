---
name: dotnet-base
description: How to use the diene.dotnet-base .NET 10 base template — pls entry points, tests, coverage, dead-code, and scope boundaries
---

# .NET Base Template

This is the AtomiCloud **.NET 10 base template** (`diene.dotnet-base`). It ships the shared local quality gates and the CI that runs them; downstream templates (API, etc.) build on top of it.

All conventions live under [`docs/developer/standard/`](../../../docs/developer/standard/) and are **mandatory** — start there, especially [ci-cd](../../../docs/developer/standard/ci-cd.md), [taskfile](../../../docs/developer/standard/taskfile.md), [shell-scripts](../../../docs/developer/standard/shell-scripts.md), [docker](../../../docs/developer/standard/docker.md), and [testing](../../../docs/developer/standard/testing/index.md).

## Entry Points (`pls`)

`pls` (Taskfile) is the only supported entry point. CI runs the same gates through the matching `scripts/ci/*` scripts (see "CI scripts vs Taskfile" below), so local and CI never drift.

| Command                                            | Purpose                                                       |
| -------------------------------------------------- | ------------------------------------------------------------- |
| `pls setup`                                        | Set up the repo (Nix env + secrets)                           |
| `pls build`                                        | Build the solution in Release                                 |
| `pls lint`                                         | Run all pre-commit hooks                                      |
| `pls test:unit` / `pls test:int`                   | Run unit / integration tests (`:dev` variants watch)          |
| `pls test:unit:coverage` / `pls test:int:coverage` | Run tests with coverage and enforce the threshold             |
| `pls dead-code` / `pls dead-code:no-test`          | Dead-code inspection (no-test treats test-only code as dead)  |
| `pls docker:prep`                                  | Validate the base Docker build context (build smoke, no push) |

Run `pls --list` for the full set.

## How It Fits Together

- **Tests & coverage** — `pls test:*` calls `scripts/local/dotnet-test.sh`; coverage mode emits a cobertura report under `TestResults/<mode>/coverage/` and enforces the per-mode minimum in `.config/dotnet-base.test.yaml`. Reports are preserved even on failure so CI can still upload the filtered reports to Codecov.
- **Dead-code** — `scripts/local/dotnet-dead-code.sh` runs JetBrains InspectCode on net10 via the repo-pinned `jb` tool; the no-test pass surfaces production code reachable only from tests.
- **CI** — `.github/workflows/ci.yaml` calls reusable pre-commit, test, and build workflows (`⚡reusable-*.yaml`), each running the matching `scripts/ci/*.sh` inside `nix develop .#ci` on NSCloud runners with the shared Nix store and NuGet caches. The same reusable test workflow is called once for unit coverage and once for integration coverage. Test artifacts upload with `if: always()`.
- **CI scripts vs Taskfile** — `scripts/ci/*` are CI-only; local tasks use `scripts/local/*` or inline one-liners. Any new gate must be a `scripts/ci/*.sh` that is reproducible locally via `nix develop .#ci -c ./scripts/ci/<script>.sh`.

## Out of Scope

Keep these **downstream-template** concerns out of this base:

- Publishing / deployment packaging — Helm, Garden, K3d, release artifacts.
- NuGet package or HTTP API surfaces.
- Production observability (metrics, tracing, dashboards).

Docker support here stops at build readiness (`pls docker:prep` / the existing Docker CI path); it does not add deployment packaging.
