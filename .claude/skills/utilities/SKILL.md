---
name: utilities
description: Common utility libraries to reduce boilerplate. Use Lodash (TS), LINQ (C#), and stdlib slices/maps + samber/lo (Go) for collections, strings, objects, and functional operations.
invocation:
  - utilities
  - utility
  - lodash
  - linq
  - samber/lo
  - collections
  - functional
  - helpers
  - map
  - filter
  - reduce
---

# Utility Libraries

## Quick Reference

### Library Support

| Language       | Primary Library        | Secondary   |
| -------------- | ---------------------- | ----------- |
| TypeScript/Bun | Lodash                 | -           |
| C#/.NET        | LINQ (native)          | -           |
| Go             | stdlib `slices`/`maps` | `samber/lo` |

### Common Operations

| Operation | TypeScript (Lodash) | C# (LINQ)        | Go (slices/lo)                                  |
| --------- | ------------------- | ---------------- | ----------------------------------------------- |
| Filter    | `filter`            | `Where`          | `lo.Filter`                                     |
| Map       | `map`               | `Select`         | `lo.Map`                                        |
| Reduce    | `reduce`            | `Aggregate`      | `lo.Reduce`                                     |
| Find      | `find`              | `FirstOrDefault` | `lo.Find`                                       |
| Group     | `groupBy`           | `GroupBy`        | `lo.GroupBy`                                    |
| Sort      | `sortBy`            | `OrderBy`        | `slices.SortFunc`                               |
| Unique    | `uniq`              | `Distinct`       | `lo.Uniq`                                       |
| Flatten   | `flatten`           | `SelectMany`     | `lo.Flatten`                                    |
| Chunk     | `chunk`             | `Chunk`          | `lo.Chunk`                                      |
| Contains  | `includes`          | `Contains`       | `slices.Contains`                               |
| Keys      | `keys`              | `dict.Keys` †    | `slices.Collect(maps.Keys(m))` or `lo.Keys`     |
| Values    | `values`            | `dict.Values` †  | `slices.Collect(maps.Values(m))` or `lo.Values` |
| Pick/Omit | `pick`/`omit`       | -                | `lo.PickByKeys`/`lo.OmitByKeys`                 |

† Dictionary properties, not LINQ operators

## Core Principles

1. **Use Libraries, Not Hand-Code** — Battle-tested utilities reduce bugs and tests
2. **Tree-Shakeable Imports** — Import only what you need (Lodash, lo)
3. **Native First** — Use native features when sufficient (array methods, LINQ)
4. **Functional Style** — Prefer map/filter/reduce over loops
5. **Readability Wins** — Named utilities are more readable than complex inline logic

## Categories

| Category    | Common Utilities                           |
| ----------- | ------------------------------------------ |
| Collections | map, filter, reduce, find, groupBy, sortBy |
| Strings     | trim, case conversion, template, truncate  |
| Objects     | pick, omit, merge, cloneDeep, keys, values |
| Functions   | debounce, throttle, memoize, once          |
| Math        | sum, mean, min, max, clamp, range          |

## See Also

Language-specific docs:
let***= if (useTypeScript) { ***

- [TypeScript](../../../docs/developer/standard/utilities/languages/typescript.md)
  let***= } ***
  let***= if (useCSharp) { ***
- [C#](../../../docs/developer/standard/utilities/languages/csharp.md)
  let***= } ***
  let***= if (useGo) { ***
- [Go](../../../docs/developer/standard/utilities/languages/go.md)
  let***= } ***

Related skills:

- [`/validation`](../validation/) — For validating collections
- [`/testing`](../testing/) — For testing with utilities
- [`/domain-modeling`](../domain-modeling/) — For using utilities in domain logic
