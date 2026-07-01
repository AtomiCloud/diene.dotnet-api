# Ubiquitous Language — Note

The ubiquitous language for the `Note` bounded context. All entities live in the
`AtomiCloud.DotnetBase.Lib.Note` module (`Lib/Note`), with concrete persistence
adapters in the `App` layer (`App/Adapters/Redis`).

## Module: Note

### Records (content, no identity)

| Term         | Definition                                                                              |
| ------------ | --------------------------------------------------------------------------------------- |
| `NoteRecord` | The content of a note — its `Title` and `Body`. Immutable by construction, no identity. |

### Principals (identity + content)

| Term            | Definition                                                                                  |
| --------------- | ------------------------------------------------------------------------------------------- |
| `NotePrincipal` | A persisted note: a stable `Id` paired with its `NoteRecord`. Identity is minted on `Save`. |

### Services (behavior)

| Term              | Definition                                                                                                                             |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `INoteSummariser` | Produces a short, single-line preview of a note for listings. Collapses whitespace and truncates on a word boundary to a max length.   |
| `NoteSummariser`  | Pure, stateless implementation of `INoteSummariser`. No state, no IO.                                                                  |
| `INoteRepository` | The persistence boundary for notes. The domain owns the contract; adapters implement it. `Save` mints identity; `Find` looks up by id. |

## Anti-terms

Words NOT to use, and what to use instead, to keep the language precise.

| Do not use              | Use instead                        | Why                                                                                     |
| ----------------------- | ---------------------------------- | --------------------------------------------------------------------------------------- |
| Memo / Entry / Item     | Note                               | One noun per concept; "note" is the agreed term for this bounded context.               |
| `Note` (bare entity)    | `NoteRecord` / `NotePrincipal`     | Always distinguish content (`Record`) from identified content (`Principal`).            |
| Summary / Description   | Preview (via `Summarise`)          | The single-line listing string is a "preview"; avoid overloaded "summary".              |
| Fetch / Load / Retrieve | `Find` (lookup) / `Save` (persist) | `Find`/`Save` are this context's repository verbs; one term per operation, no synonyms. |
