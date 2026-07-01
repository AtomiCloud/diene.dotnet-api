# Code Rules

Use these shared standards as the source of truth for AtomiCloud code:

- [Software Design Philosophy](docs/developer/standard/software-design-philosophy/index.md)
- [SOLID Principles](docs/developer/standard/solid-principles/index.md)
- [Functional Practices](docs/developer/standard/functional-practices/index.md)
- [Domain-Driven Design](docs/developer/standard/domain-driven-design/index.md)
- [Three-Layer Architecture](docs/developer/standard/three-layer-architecture/index.md)
- [Stateless OOP and Dependency Injection](docs/developer/standard/stateless-oop-di/index.md)
- [Validation](docs/developer/standard/validation/index.md)
- [Date/Time](docs/developer/standard/datetime/index.md)
- [Testing](docs/developer/standard/testing/index.md)
- [Utilities](docs/developer/standard/utilities/index.md)
- [Contributor Docs](docs/developer/standard/contributor-docs/index.md)
- [Contributor Docs Checklist](docs/developer/standard/contributor-docs/checklist.md)
- [Contributor Docs Classification](docs/developer/standard/contributor-docs/classification.md)
- [Contributor Docs Frontmatter](docs/developer/standard/contributor-docs/frontmatter.md)
- [Contributor Docs Structure](docs/developer/standard/contributor-docs/structure.md)

Only selected language-specific standards are generated. Do not link to missing language docs.

- [C# SOLID Principles](docs/developer/standard/solid-principles/languages/csharp.md)
- [C# Functional Practices](docs/developer/standard/functional-practices/languages/csharp.md)
- [C# Domain-Driven Design](docs/developer/standard/domain-driven-design/languages/csharp.md)
- [C# Stateless OOP and DI](docs/developer/standard/stateless-oop-di/languages/csharp.md)
- [C# Validation](docs/developer/standard/validation/languages/csharp.md)
- [C# Date/Time](docs/developer/standard/datetime/languages/csharp.md)
- [C# Testing](docs/developer/standard/testing/languages/csharp.md)
- [C# Utilities](docs/developer/standard/utilities/languages/csharp.md)

# Base Template (diene.dotnet-base)

This repo is the AtomiCloud **.NET 10 base template**. Everything above is the mandatory convention source — treat `docs/developer/standard/` as binding. When working here:

- **Use `pls` (Taskfile) as the entry point** for every task — `pls build`, `pls lint`, `pls test:unit`, `pls test:int`, `pls test:unit:coverage`, `pls test:int:coverage`, `pls dead-code`, `pls docker:prep`. These run the same gates CI runs (CI invokes the matching `scripts/ci/*` scripts under `nix develop .#ci`); do not invent ad-hoc `dotnet`/`docker` invocations. See `.claude/skills/dotnet-base/SKILL.md`.
- **Follow .NET 10 conventions** — the SDK is pinned via `global.json`; build and test in Release. CI runs in `nix develop .#ci`, so any new gate must be a `scripts/ci/*.sh` script reproducible locally.
- **Respect template-merge constraints** — keep edits minimal and line-oriented (append-only where possible, stable ordering) so three-way template merges stay clean.
- **Keep downstream concerns out** — this base stops at local gates and the CI that runs them. Publishing, deployment packaging (Helm/Garden/K3d), NuGet/API surfaces, and production observability belong to downstream templates, not here.
