---
name: three-layer-architecture
description: Three-layer architecture with guardrails → logic → storage. Use when designing application architecture, adding new endpoints, or implementing data persistence.
invocation:
  - architecture
  - layers
  - three-layer
  - layer
  - mapper
  - repository
  - controller
  - adapter
  - hexagonal
  - domain-layer
---

# Three-Layer Architecture

## The Three Layers

```text
API Layer (Guardrails) → Domain Layer (Logic) → Data Layer (Storage)
```

| Layer  | Responsibility                                              |
| ------ | ----------------------------------------------------------- |
| API    | Type enforcement, validation, auth, mapping, serialization  |
| Domain | Business logic, state machines, calculations (zero IO)      |
| Data   | Indexes, data structures, query optimization, error mapping |

## Layer Constraints

- **API layer**: Zero business logic, only guardrails
- **Domain layer**: Zero IO, defines interfaces for dependencies
- **Data layer**: Implements domain interfaces, translates errors

## Separate Models Per Layer

| Layer  | Model Type       | Optimized For          |
| ------ | ---------------- | ---------------------- |
| API    | Req/Res          | Transport (JSON, CLI)  |
| Domain | Principal/Record | Business logic         |
| Data   | Data/Entity      | Storage (ORM, indexes) |

## Mappers

- **API Mapper**: External ↔ Domain (Req.ToDomain, domain.ToRes)
- **Data Mapper**: Domain ↔ Storage (data.ToDomain, domain.ToData)

**Mapper Rules:**

1. Composable — higher-level mappers reuse lower-level
2. SRP grouping — update requests target records by update rate
3. ToData mutates — preserves ID/PK for ORM compatibility (this is an adapter-layer exception to the immutability rule in [`/stateless-oop-di`](../stateless-oop-di/); mutability is inevitable at the storage boundary)

## Error Flow

```text
Infrastructure error → Domain error → Transport error (e.g., ProblemDetails)
```

Errors are values, not exceptions. Each layer has its own error type.

## Dependency Direction

Dependencies point inward:

- API depends on Domain
- Data depends on Domain
- Domain depends on nothing (defines interfaces)

## See Also

Full documentation: [three-layer-architecture/](../../../docs/developer/standard/three-layer-architecture/)

Related skills:

- [`/stateless-oop-di`](../stateless-oop-di/) — For wiring the composition root
- [`/testing`](../testing/) — For testing pure domain logic with mocks
- [`/domain-modeling`](../domain-modeling/) — For modeling the domain layer
- [`/error-handling`](../error-handling/) — For Result types and error mapping
- [`/validation`](../validation/) — For validation placement at API boundary
