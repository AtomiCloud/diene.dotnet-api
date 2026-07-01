---
name: datetime
description: Date and time handling across languages using Temporal (TS), native types (C#), and standard library (Go). Use when working with dates, times, timezones, durations, or scheduling.
invocation:
  - datetime
  - date
  - time
  - timezone
  - duration
  - instant
  - temporal
  - schedule
  - calendar
---

# Date/Time Handling

## Quick Reference

### Types by Purpose

| Use Case          | TypeScript               | C#                                     | Go                                      |
| ----------------- | ------------------------ | -------------------------------------- | --------------------------------------- |
| **Point in time** | `Temporal.Instant`       | `DateTimeOffset`                       | `time.Time`                             |
| **Date only**     | `Temporal.PlainDate`     | `DateOnly`                             | ❌ None (use `time.Time` w/ convention) |
| **Time only**     | `Temporal.PlainTime`     | `TimeOnly`                             | ❌ None (use `time.Time` w/ convention) |
| **Date + Time**   | `Temporal.PlainDateTime` | `DateTimeOffset` (prefer) / `DateTime` | `time.Time`                             |
| **With timezone** | `Temporal.ZonedDateTime` | `DateTimeOffset`                       | `time.Time`                             |
| **Duration**      | `Temporal.Duration`      | `TimeSpan`                             | `time.Duration`                         |
| **Timezone info** | `string` (IANA tz id)    | `TimeZoneInfo`                         | `*time.Location`                        |

> ⚠️ **Go Note**: Unlike C# and TypeScript, Go has **no true DateOnly or TimeOnly types**. Use `time.Time` at midnight UTC with convention for date-only semantics.

### Library Support

| Language       | Library/Type System                         |
| -------------- | ------------------------------------------- |
| TypeScript/Bun | `@js-temporal/polyfill` (Temporal API)      |
| C#/.NET        | Native (`DateTime`, `DateTimeOffset`, etc.) |
| Go             | Standard library (`time` package)           |

## Core Principles

1. **Know Your Types** — Instant (point in time), Date (calendar), Time (clock), Duration (elapsed)
2. **Timezone Awareness** — Always be explicit about timezones; prefer UTC for storage
3. **Use the Right Type** — DateOnly for birthdays, Instant for timestamps, Duration for intervals (C#/TS only; Go uses `time.Time` with convention)
4. **Avoid `Date` Object in JS** — Use Temporal; native Date is broken (months 0-indexed, etc.)
5. **Prefer `DateTimeOffset` in C#** — Unambiguous point in time; avoid `DateTime` kind confusion
6. **Go Uses `time.Time` for Everything** — No third-party library needed; use UTC midnight convention for date-only

## Common Pitfalls

| Pitfall                    | Problem                       | Solution                                                                      |
| -------------------------- | ----------------------------- | ----------------------------------------------------------------------------- |
| Timezone confusion         | System vs user vs UTC         | Always store UTC, display local                                               |
| DST transitions            | 1 hour may not equal 1 hour   | Use Instant/Durations for scheduling                                          |
| Birthday in wrong tz       | Date changes with timezone    | Use PlainDate/DateOnly for birthdays (Go: `time.Time` at UTC midnight)        |
| `DateTime.Now` in C#       | Kind=Local, ambiguous         | Use `DateTimeOffset.UtcNow`                                                   |
| JS `Date` month index      | Months are 0-indexed          | Use Temporal API                                                              |
| `time.Sleep` for durations | Not precise, blocks goroutine | Use `time.After`, `time.NewTimer`, `time.NewTicker`, or `context.WithTimeout` |

## See Also

Full documentation: [datetime/](../../../docs/developer/standard/datetime/)

Related skills:

- [`/validation`](../validation/) — For validating date inputs
- [`/domain-modeling`](../domain-modeling/) — For date/time domain types
