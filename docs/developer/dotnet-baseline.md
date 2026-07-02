---
id: dotnet-baseline
title: .NET Baseline
---

# .NET Baseline

`dotnet-base` is the .NET foundation for `AtomiCloud/diene.dotnet-base`. It is a
**sibling-template foundation**: sibling templates (library, API) copy it and
adapt a small set of settings (see [Template maintenance](#template-maintenance))
before formal CyanPrint template promotion.

Only .NET-specific baseline behavior is documented here. General standards stay
in `docs/developer/standard/`.

## Local commands

New .NET entries:

- `pls build`
- `pls test:unit`, `pls test:unit:coverage`, `pls test:unit:dev`
- `pls test:int`, `pls test:int:coverage`, `pls test:int:dev`
- `pls dead-code`
- `pls docker:prep`

## Solution layout & test modes

Four projects in `dotnet-base.slnx`, split so the fast path stays Docker-free:

- **`Lib`** — pure domain code; covered by **`UnitTest`** (xunit.v3). No
  containers; this is the default fast path.
- **`App`** — the runnable composition root wiring adapters (Redis); covered by
  **`IntTest`** against a throwaway Redis container via Testcontainers. Slow and
  Docker-dependent, so it lives on a dedicated path.

The same `tasks/Taskfile.test.yaml` recipe serves both suites (parameterised by
mode) — there is one test recipe, not two.

## Coverage gates

- Coverage config lives in `.config/dotnet-base.test.yaml`: unit enforces its
  minimum on `[Lib]*`, integration on `[App]*` (coverlet filters).
- The local coverage gate is blocking (`pls test:unit:coverage`,
  `pls test:int:coverage` — the same scripts CI runs).
- Codecov upload is non-blocking and split by `unit` / `int` flags.
- `codecov.yml` statuses are informational by default.

## Build, supply chain & runtime

- `pls build` (and `scripts/ci/build.sh`) build the solution in Release with
  warnings as errors.
- **NuGet audit** runs at restore (`NuGetAudit` + `NuGetAuditMode=all` in
  `Directory.Build.props`): a known CVE in any direct or transitive package
  fails the build. Loud by design; if a dependency is vulnerable, bump it.
- Builds are deterministic; CI additionally sets `ContinuousIntegrationBuild`
  (gated on `$CI`) so artifacts are reproducible and stamp-friendly.
- `infra/Dockerfile` is a **placeholder**: `pls docker:prep` only validates the
  build context. Downstream templates replace it with a real image.

## Release & delivery

- semantic-release (conventional commits, `atomi_release.yaml`) computes the
  version, commits `Changelog.md`, tags `v*.*.*`, and creates the GitHub
  release. `.github/workflows/release.yaml` runs it after CI succeeds on
  `main`.
- The tag triggers `cd.yaml`, which builds and pushes the docker image. Images
  land at the repo-scoped path `ghcr.io/atomicloud/<repo>/<image_name>`.
- Workflow jobs that push images need `permissions: { id-token: write,
packages: write }` (namespace OIDC + ghcr); the repo setting
  `default_workflow_permissions` must be `write` for semantic-release to create
  GitHub releases. New repos start at `read` — set it before the first release.

## External service / compute cost

- Codecov upload runs only in CI and is best-effort.
- Integration tests and the docker prep job require a Docker runtime.
- Pre-commit, dead-code, unit, integration, build, and docker are separate CI
  jobs.

## Template maintenance

`dotnet-base` is consumed by sibling templates before formal template
promotion. Keep CyanPrint-managed/shared scaffold edits additive. Settings a
downstream template is expected to adapt:

- **Docker image name** — `image_name` in `ci.yaml`/`cd.yaml`,
  `tasks/Taskfile.docker.yaml`, and `scripts/ci/docker-prep.sh`.
- **Coverage thresholds** — `.config/dotnet-base.test.yaml` minimums and
  `codecov.yml` flags.
- **Docker runtime** — `infra/Dockerfile` is replaced wholesale downstream.
- **Badges / template promotion** — the `AtomiCloud/diene.dotnet-base` paths in
  `README.md` badges are rewritten on promotion.
- **Sample source/tests** — the `Note` domain (`Lib/Note`, `App/Adapters`,
  matching `UnitTest`/`IntTest` suites) is illustrative and replaced per
  service. Repo-internal scaffold names (`dotnet-base.slnx`,
  `.config/dotnet-base.test.yaml`, `RootNamespace AtomiCloud.DotnetBase.*`)
  intentionally stay base-named to keep the three-way-merge surface minimal.

Merge ownership stays manual: CI is driven to green, but the actual merge is a
human action.
