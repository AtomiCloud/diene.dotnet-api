# Development Environment

[![CI](https://github.com/AtomiCloud/diene.dotnet-base/actions/workflows/ci.yaml/badge.svg)](https://github.com/AtomiCloud/diene.dotnet-base/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/AtomiCloud/diene.dotnet-base/branch/main/graph/badge.svg)](https://codecov.io/gh/AtomiCloud/diene.dotnet-base)

This is the AtomiCloud **.NET 10 base template**. It carries the shared local quality gates (build, lint, tests, coverage, dead-code, Docker prep) and the CI that runs them — downstream templates (API, etc.) build on top of it.

All binaries, tools, and PATH are managed by **Nix**. Do not install tools manually or modify PATH outside of the nix configuration.

## Prerequisites

1. **[Nix](https://nixos.org/download)** — package manager
2. **[Docker](https://docs.docker.com/get-docker)** — container runtime
3. **[direnv](https://direnv.net/docs/installation.html)** — auto-loads the nix shell on `cd`

## Getting Started

```bash
direnv allow    # first time only — loads the nix dev shell
```

Once allowed, direnv automatically loads the development environment whenever you enter the project directory.

## Usage

[`pls`](docs/developer/standard/taskfile.md) (Taskfile) is the entry point for every local task — the same gates CI runs (CI invokes the matching `scripts/ci/*` scripts under `nix develop .#ci`):

| Command                  | What it does                                                        |
| ------------------------ | ------------------------------------------------------------------- |
| `pls setup`              | Set up the repo (Nix env + secrets)                                 |
| `pls build`              | Build the .NET solution (Release)                                   |
| `pls lint`               | Run all pre-commit hooks across the code-base                       |
| `pls test:unit`          | Run unit tests (`:int` for integration; `:dev` variants watch)      |
| `pls test:unit:coverage` | Run tests with coverage and enforce the threshold (`:int:coverage`) |
| `pls dead-code`          | Inspect for dead code                                               |
| `pls docker:prep`        | Validate the base Docker build context (build smoke, no push)       |

Run `pls --list` to see every available task.

CI (`.github/workflows/ci.yaml`) wires the same entry points through reusable pre-commit, test, and build workflows, uploads test-result and coverage artifacts, and keeps the Docker image build valid. Coverage configuration lives in `.config/dotnet-base.test.yaml`; CI uploads those filtered unit and integration reports to Codecov. Publishing, deployment packaging, and production observability are downstream-template concerns and intentionally out of scope here.

## Nix Configuration

See [docs/developer/standard/nix.md](docs/developer/standard/nix.md) for the full guide on:

- File structure (`flake.nix`, `nix/`, `.envrc`)
- Adding/removing packages
- Environment groups and shells
- Formatters and pre-commit hooks
- Adding registries
