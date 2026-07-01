# goal — `diene.dotnet-api`

> A sample **ASP.NET web API** template that proves the reusable AtomiCloud
> service patterns end-to-end, ready to be lifted into a CyanPrint template.
> Derived from [`diene.dotnet-base`](../dotnet-base); reference
> [`AtomiCloud/alcohol.zinc`](https://github.com/AtomiCloud/alcohol.zinc),
> upgraded to newest .NET + newest practice.

## 1. What this repo is

- A **runnable, deployable ASP.NET Core service sample** — a real HTTP host with
  endpoints, health, config, observability, container image, and Helm deploy.
  It exists to prove the full service delivery chain on top of `dotnet-base`,
  using additive changes.
- The sample feature is **illustrative and swappable** (reuse base's `Note`
  domain). A downstream clones this, replaces the module, and keeps the host,
  observability, testing, and deploy machinery.
- It is the **.NET analogue of [`diene.bun-cli`](../bun-cli)** (base → deployable
  app). Same additive "add the app + delivery layer" philosophy — but where
  bun-cli's Helm chart is a stub (a CLI isn't long-running), **dotnet-api is a
  service, so its chart is real** (Deployment/Service/probes/HPA/config), closer
  to alcohol.zinc's `api_chart`.

## 2. Spirit to capture (from alcohol.zinc)

- **Thin `Program.cs` → fat composition root** (`StartUp/Server.cs`) with a
  **dual run mode**: `Server` (serve) and `Migration` (run migrations, exit).
- **Feature-module architecture**: `App/Modules/<Feature>/{API/V1, Data, ...}` —
  each module owns its endpoints, data, mappers, validators.
- **Errors as data**: `Result<T>` chaining + an `IDomainProblem` hierarchy
  rendered as **RFC-7807 ProblemDetails** with a uniform error contract.
- **Config as typed, validated options**: layered YAML
  (`settings.yaml` + `settings.<landscape>.yaml`) + env vars, bound to
  `IOptionsMonitor<T>` with **fail-fast startup validation**.
- **Observability-first**: OpenTelemetry traces + metrics + logs over OTLP —
  vendor-neutral, no hand-rolled console logging.
- **Full delivery chain**: multi-stage container image + reusable CI workflows +
  semantic-release + Helm charts with per-landscape values + Nix/Taskfile.

## 3. High-level goals

### 3.1 Convert the host: console → web

- `App/App.csproj` → `Sdk="Microsoft.NET.Sdk.Web"`, drop `OutputType=Exe`.
- Replace `App/Program.cs` console flow with a **thin bootstrap** + a
  composition root (`App/StartUp/Server.cs`) using layered service registration
  (logging → options → versioning → endpoints → OTEL → cache → domain → jobs),
  each a small extension method.

### 3.2 Endpoints (one sample module)

- One feature module reusing the existing `Note` domain, e.g.
  `App/Modules/Note/API/V1/` exposing CRUD.
- **Default to minimal APIs with typed results** (`TypedResults`, `MapGroup`,
  endpoint filters for validation) — less boilerplate than MVC controllers for
  a template. Controllers optional/secondary.

### 3.3 Cross-cutting service concerns

- **Typed, validated config**: `App/Config/settings.yaml` (+ landscape
  overrides), typed options, validate-on-start.
- **Error pipeline**: `App/Error/` domain problems + `IExceptionHandler` +
  `AddProblemDetails()` → RFC-7807 responses.
- **Health/readiness**: `/health` (+ liveness/readiness tags) via built-in
  health checks; **OpenAPI** document endpoint.
- **Validation**: FluentValidation wired via endpoint filters.

### 3.4 Observability

- OpenTelemetry via `AddOpenTelemetry()` — traces + metrics + logs with ASP.NET/
  HTTP/runtime auto-instrumentation and an OTLP exporter.

### 3.5 Testing

- Add `Microsoft.AspNetCore.Mvc.Testing` to `IntTest`; add a
  **`WebApplicationFactory`-based endpoint test** alongside base's existing
  Testcontainers Redis integration test.
- Keep unit tests for domain/mappers/validators.

### 3.6 Container image

- Replace base's placeholder `infra/Dockerfile` with a **real multi-stage image**:
  `dotnet sdk` build → `aspnet` runtime publish of `App.dll`, non-root,
  cross-arch (`$TARGETARCH`), `EXPOSE 8080`. Keep base's `image_name` wiring and
  the shared `scripts/ci/docker.sh` publish (commit/branch/latest/semver tags to
  ghcr.io).
- `docker:run` task curls the health endpoint as a smoke check.
- Add `infra/migrate.Dockerfile` (EF bundle image, run as a pre-deploy Job)
  **only if** persistence/migrations are included — see §4 note.

### 3.7 Deploy — Helm (the main net-new delivery piece)

- Mirror how bun-cli added deploy over bun-base, but with a **real chart**:
  - `infra/root_chart/` with Deployment, Service, liveness/readiness probes,
    HPA, and configmap-mounted settings (+ per-landscape values).
  - `tasks/Taskfile.helm.yaml`, `scripts/ci/helm.sh` (stamps `appVersion` to
    match the image, OCI push).
  - `.github/workflows/⚡reusable-helm.yaml` + a **helm job** in both `ci.yaml`
    (lint/template) and `cd.yaml` (publish on `v*.*.*`).

### 3.8 Docs

- `docs/developer/dotnet-api-baseline.md` (parallel to bun's `bun-baseline.md`):
  new `pls` tasks, run modes, and the **promotion knobs** a downstream adapts
  (see §5).

## 4. Newest-practice upgrades (alcohol.zinc is .NET 8)

- **Target .NET 10** (base already does) end-to-end — not net8.0.
- **Native OpenAPI** (`Microsoft.AspNetCore.OpenApi`, `MapOpenApi()`) + a light
  UI (Scalar) instead of Swashbuckle.
- **Minimal APIs + `TypedResults`** as the default; MVC controllers optional.
- **`IExceptionHandler` + `AddProblemDetails()`** (built-in) instead of a
  hand-rolled base-controller exception mapper.
- **Built-in health checks** with liveness/readiness tags.
- **Modernise the OTEL stack** package versions (alcohol's approach is already
  sound — just current packages).
- **Container hardening**: chiseled/distroless runtime
  (`dotnet/aspnet:10.0-*-chiseled`) or `dotnet publish /t:PublishContainer`;
  optionally trimmed/AOT for a slim minimal-API image; non-root, port 8080.
- **Options validate-on-start** (source-gen validation where available).
- Keep FluentValidation, but wire via **endpoint filters**, not controller
  injection.
- **Persistence is optional for the sample.** alcohol.zinc uses Postgres + EF +
  a bundled-migration image; a minimal API sample can stay in-memory / reuse
  base's Redis adapter and **document** the EF+migration+`migrate.Dockerfile`
  pattern as the extension point, to keep the sample lean and 3wm-friendly.
  Decide explicitly during implementation.

## 5. Promotion knobs (what a downstream template swaps)

- Service / image name, `EXPOSE` port, Docker entrypoint.
- The sample feature module (replace `Note` with the real domain).
- `settings.yaml` keys + typed options.
- Helm values (replicas, resources, probes, ingress host, HPA).
- Coverage thresholds, README badges, baseline-doc settings.

## 6. Non-negotiable constraint — minimize the 3wm surface

- `main` here is an **exact copy of `dotnet-base`** (the bootstrap commit is the
  3-way-merge base). When upstream `dotnet-base` changes, downstream repos must
  merge cleanly.
- Prefer **additive, line-level** changes and **new files**
  (`App/StartUp/`, `App/Modules/`, `App/Config/`, `App/Error/`, `infra/root_chart/`,
  `scripts/ci/helm.sh`, new workflows). Where base files must change (e.g.
  `App.csproj` SDK, `Program.cs`), keep edits minimal and localised.
- Base already provides (reuse as-is, do **not** re-edit): Nix shells,
  Taskfile + `tasks/*`, `scripts/ci/*` incl. shared `docker.sh`, Central Package
  Management, .NET 10 target, xUnit v3 + FluentAssertions 7 + Testcontainers,
  coverage config, CI with docker job, `cd.yaml` docker job, semantic-release.

## 7. Out of scope

- Publishing as a NuGet library — that's `dotnet-lib`.
- A full multi-module business domain, real auth provider, email/storage
  integrations — the sample proves the _shape_ with one module; these are
  documented extension points, not built out.
