# Case-study oracle: expected changes per release

Ramdaf exists to test `lem`'s compatibility checker on a real library's
history. Each commit on this branch ports one Ramda release, and `lem publish`
classifies the commit's API change against the previous one. To judge those
classifications, every release commit carries a manifest of the changes we
**expect** a Dafny client to see, written from Ramda's behaviour (checked in
node at the tag) and from the port's own diff, never from `lem`'s output.

A later comparison lines these manifests up, per symbol, with the rows `lem`
actually records, keyed by the Lemmata commit and the Ramdaf commit.

## Files

`casestudy/expected/<ramda-tag>.json`, added in the commit that ports
`<ramda-tag>` (for example `casestudy/expected/v0.1.1.json` in the
`Port Ramda v0.1.1` commit).

## Schema

```json
{
  "ramda": "v0.1.1",
  "tier": "major",
  "changes": [
    {"symbol": "Ramdaf.List.foldr", "kind": "breaking", "why": "Ramda v0.1.1 passes (acc, x) to the callback; the signature changed"},
    {"symbol": "Ramdaf.List.findIndex", "kind": "added", "why": "new in v0.1.1"},
    {"symbol": "Ramdaf.Functions.fog", "kind": "removed", "why": "alias dropped upstream"}
  ]
}
```

- `ramda`: the Ramda tag the commit ports.
- `tier`: what a Dafny client should expect from the release:
  - `major` if any exported symbol was removed or renamed, or changed its
    signature or observable meaning;
  - `minor` only for a change that is compatible but may need a hint in a
    dependent proof (for example a body made opaque);
  - otherwise `patch`. `lem` treats pure additions as patch by design.
- `changes`: one entry per affected exported symbol.
  - `symbol`: the fully qualified Dafny name of an **exported** declaration as
    clients see it, `Ramdaf.<Area>.<name>`. Exported datatypes and types count
    too (for example `Ramdaf.Prelude.Option`). Private helpers and lemmas never
    appear.
  - `kind`: one of the four below.
  - `why`: one line citing the Ramda change.

## Kinds

| kind | meaning |
|---|---|
| `added` | a new exported symbol |
| `removed` | an exported symbol is gone |
| `breaking` | any change a client can observe as incompatible: a signature or type change, a strengthened precondition, a weakened postcondition, or any change in the result for an input that was in the domain before (for a revealed function the body is the behaviour) |
| `compatible` | the contract only grows: a weakened precondition, a strengthened postcondition, or newly defined behaviour where it was undefined before, with every previously defined result unchanged |

## Rules

- A rename is a removal plus an addition.
- Knock-on changes count. An exported function whose observable behaviour
  changes because something it calls changed (for example `reduceRight` when
  `foldr` changes, or `union` when `uniq` changes) is itself `breaking`, even
  if its own text did not change. Decide by behaviour, checked in node where
  useful.
- Every exported symbol not listed is expected **unchanged**: its observable
  behaviour and contract are identical. So a missing entry is a claim, and the
  manifest must be complete.
- A revealed body that is **rewritten** is `compatible` even when every result
  is identical (for example a function that now calls another exported function
  to compute the same values). The revealed body is what a dependent's proof
  unfolds, so a dependent verified against the new release may rely on its new
  form; `lem` rows such a change `compatible`, and the last-change floor counts
  it. Only a change in results makes it `breaking`.
- Knock-on changes count at both strengths: an exported function whose revealed
  body or contract names something that changed `compatible` is itself
  `compatible` (unless it is `breaking` for its own reasons).
- Comment-only edits, and changes to private helpers that leave every exported
  contract and revealed body's text identical, are not listed.
