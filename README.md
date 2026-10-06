# Ramdaf

A verified Dafny port of [Ramda](https://github.com/ramda/ramda), the
functional JavaScript library, ported release by release through its 63 tagged
releases (v0.1.0, Dec 2013 → v0.32.0, Oct 2025).

## Purpose

Ramdaf is a case study of [Lemmata](https://registry.lemmata.sh)'s
compatibility checker (`lem`) on a real library's history. Each commit on this
branch ports exactly one Ramda release, then `lem publish` decides the version
bump from the change in the verified API. That only says something about `lem`
if each commit matches its Ramda release exactly, or states precisely where the
Dafny encoding cannot. That is the rule this README and the conventions below
enforce.

## Workflow

For each Ramda tag, in order:

1. `git -C ramda checkout <tag>`. The Ramda clone lives in the ignored
   `ramda/` directory.
2. Diff `ramda.js` and `test/` against the previous tag.
3. Port the changes into `src/*.dfy` following the porting conventions.
   Transcribe the changed Ramda tests into `tests/ramda/`, and add node-checked
   edge cases to `tests/edge/`.
4. Check that `src` verifies with zero warnings and that every test passes
   (`lem test`, or the Dafny commands under "Toolchain").
5. Update the "Deviations" and "Not portable" tables and add a "Release
   changelog" entry.
6. Make one commit, `Port Ramda <tag>`.
7. Run `lem publish`, then tag the commit `ramda-<tag>` and record the version
   `lem` assigned.

## Porting conventions

- **Modules.**
  - One module per area file. `src/<Area>.dfy` holds `module Ramdaf.<Area>`.
    The areas are Core, Functions, List, Sort, Object, Logic, Math, String and
    Data. `Prelude` holds the support datatypes.
  - A new function goes in the area of the `ramda.js` section that defines
    it: "Core Functions" → Core, "Function functions" → Functions, "List
    Functions" → List, "Object Functions" → Object, "Logic Functions" → Logic,
    "Arithmetic Functions" → Math, "String Functions" → String, "Data
    Analysis and Grouping Functions" → Data, and "Miscellaneous Functions" →
    Functions.
  - There are established exceptions: sorting goes in Sort (`comparator`,
    `sort`, `sortBy`); the `always` family goes in Functions; `size` is in
    Core; `propEq` is in Object.
  - A function never moves between modules once ported, since `lem` would
    read the move as a rename.
- **Export sets.**
  - Each module's export set lists exactly that area's Ramda exports for the
    release. An alias is its own function whose body calls the original.
  - A function is `reveals`ed when its body uses only Dafny built-ins and
    exported functions; the body is then the behaviour `lem` diffs.
  - A function whose body needs private helpers is exported with `provides`
    and must carry postconditions that determine its result. Today that is
    `sort` and `sortBy`.
  - Helpers and lemmas are never exported. The only other exports are the
    support declarations listed below.
- **Signatures.**
  - Functions use Ramda's names and parameter order, uncurried.
  - Ramda's `map` is `mapSeq`, because `map` is a Dafny keyword.
  - Types follow the JS → Dafny mapping.
- **Preconditions** appear only where Ramda's result cannot be represented (a
  non-element, `undefined` holes, `NaN`, ±`Infinity`) or where Ramda throws.
  Each one is listed under "Outside the modeled domain".
- **Deviations.** Every difference from node on representable input gets two
  things:
  - a row in "Deviations";
  - a comment at the definition.

  A behavioural difference also gets a pinning test named `Deviation*` in
  `tests/edge/`.
- **Tests.**
  - `tests/ramda/*.dfy` transcribes the release's `test/test.*.js`, with one
    `{:test}` method per `it` so that one failure cannot hide another. Each
    file cites its source file, and its header lists the `it`s it skips and
    why.
  - `tests/edge/*.dfy` adds cases Ramda's suite misses. Their expected values
    are node's output for that release (ground truth: `node -e` with the
    tag's `ramda.js`).
- **Verification.**
  - `src/*.dfy` verifies with zero warnings, because `lem publish` aborts on
    warnings in the package's own source.
  - `src` has no `assume`, `{:axiom}`, `{:verify false}` or `{:test}`.
  - `{:isolate_assertions}` is allowed on a slow proof.

## JS → Dafny mapping

| JavaScript | Dafny |
|---|---|
| array (list) | `seq<T>` |
| plain object | `map<string, V>` (no key order) |
| a property that is absent or `undefined` | `None` of `Ramdaf.Prelude.Option<V>` |
| a documented "no value" result (`find` miss → `false`, `nth` out of range → `null`, `maxWith([])` → `undefined`) | `Option<T>` |
| nested arrays (`flatten`'s input) | `Ramdaf.Prelude.Tree<T>`: `Leaf(v)` or `Node(children)` |
| number | `int`, or `real` for `divide`/`divideBy` |
| string | `string` (a sequence of Unicode code points) |
| predicate, "truthy" result | `T -> bool` |
| comparator `(a, b) -> negative/0/positive` | `(T, T) -> int` |
| `===` | `==` (structural; see "Deviations") |
| multi-argument function, auto-curried | an **uncurried** Dafny function with the same parameter order. Dafny cannot partially apply a function, so `f(a)` becomes `x => f(a, x)`. |
| a call with no arguments, `f()` | `f(())` when the function takes one argument of any type |

## Modules and exports (v0.1.0)

| Module | Exports |
|---|---|
| `Ramdaf.Core` | clone, isEmpty, prepend, cons, head, car, tail, cdr, append, push, merge, concat, identity, I, size |
| `Ramdaf.Functions` | compose, fog, pipe, sequence, flip, always, alwaysZero, alwaysFalse, alwaysTrue |
| `Ramdaf.List` | foldl, reduce, foldl1, foldr, reduceRight, foldr1, unfoldr, mapSeq (`map`), filter, reject, takeWhile, take, skipUntil, skip, drop, find, all, every, any, some, contains, uniq, pluck, flatten, zipWith, zip, xprodWith, xprod, reverse, range, indexOf, lastIndexOf, join, splice, nth |
| `Ramdaf.Sort` | comparator; sort and sortBy by contract (`provides`) |
| `Ramdaf.Object` | eq, prop, get, props, keys, values, pick, pickAll, omit, eqProps, propEq |
| `Ramdaf.Logic` | and, or, not, andFn, orFn, notFn, allPredicates, anyPredicates |
| `Ramdaf.Math` | add, multiply, subtract, subtractN, divide, divideBy, sum, product, lt, lte, gt, gte, max, maxWith, minWith, min |
| `Ramdaf.String` | substring, substringFrom, substringTo, charAt, charCodeAt, strIndexOf, strLastIndexOf, toUpperCase, toLowerCase, split |
| `Ramdaf.Data` | union, unionWith, difference, differenceWith, intersection, intersectionWith, countBy, groupBy, project |

That is 116 of Ramda v0.1.0's 138 export names (121 distinct functions plus 17
aliases). The other 22 are listed under "Not portable".

### Support declarations

These are exported but are not Ramda functions:

- `Ramdaf.Prelude` reveals the datatypes `Option` and `Tree` from the mapping.
- Some modules `provides` an import alias, because an exported signature,
  postcondition or revealed body names that module:
  - `Prelude` in List, Object, Math and Data;
  - `List` in Sort and Data;
  - `Object` in Data.

### Internal Ramda functions

Ramda v0.1.0 does not export `uniqWith`, `containsWith` or `keyValue`; they
are local `var`s in `ramda.js`. Ramdaf does not export them either. The
`*With` functions in Data carry `uniqWith`'s recursion themselves.

## Not portable

These Ramda v0.1.0 exports are not ported, rather than faked:

| Export | Why |
|---|---|
| `curry` | Ramdaf functions are uncurried, and Dafny has no partial application to curry into. |
| `nAry`, `arity` | Change a function's reported arity (`fn.length`), which Dafny functions do not have. |
| `invoker`, `func` | Call a method looked up by name on an object at run time. |
| `useWith`, `use` | Variadic argument transformers. |
| `lPartial` (`applyLeft`), `rPartial` (`applyRight`) | Variadic partial application. |
| `memoize`, `once` | Rely on hidden mutable state, and `memoize`'s cache is keyed by `String(arg)`. |
| `wrap` | Variadic wrapper (`wrapper(fn, ...arguments)`). |
| `construct` | Calls JS constructors with `new`. |
| `tap` (`K`) | Its purpose is a side effect (`fn(x)`), which a pure function cannot have. |
| `maybe` | Inspects how many arguments arrived and whether they are `null`/`undefined`. |
| `generator` | Infinite lazy lists, `length: Infinity`. |
| `installTo` | Copies the library onto a global or host object. |
| `isAtom` | Tests the run-time type of an arbitrary value. |
| `match` | Regular expressions. |

## Outside the modeled domain (preconditions)

| Function | Ramda v0.1.0 (node) | Ramdaf |
|---|---|---|
| `head`, `car` | `head([])` → `[]`, the empty list itself rather than an element | `requires \|list\| > 0` |
| `foldl1`, `foldr1` | throw `Error` on `[]` | `requires \|list\| > 0` |
| `take` | `take(5, [1, 2])` → `[1, 2, <3 empty items>]`; `take(-1, l)` throws `RangeError` | `n: nat`, `requires n <= \|list\|` |
| `skip`, `drop` | `skip(-1, [1, 2])` → `[undefined, 1, 2]` | `n: nat` |
| `zip`, `zipWith` | read past the end of the second list: `zip([1, 2], [3])` → `[[1, 3], [2, undefined]]`, `zipWith(add, [1, 2], [10])` → `[11, NaN]` | `requires \|a\| <= \|b\|` |
| `charCodeAt` | `charCodeAt(10, "abc")` → `NaN` | `requires 0 <= n < \|s\|` |
| `max`, `min` | `max([])` → `-Infinity`, `min([])` → `Infinity` | `requires \|list\| > 0` |
| `divide`, `divideBy` | `divide(1, 0)` → `Infinity` | `requires` a nonzero divisor |

## Deviations

These are differences on input the encoding can represent. A behavioural
difference is pinned by a `Deviation*` test in `tests/edge/`; a difference in
a signature (an arity or an operand type) is enforced by the types.

| Function(s) | Ramda v0.1.0 (node) | Ramdaf | Why |
|---|---|---|---|
| `eq`, `contains`, `indexOf`, `lastIndexOf`, `uniq`, `union`, `difference`, `intersection`, `propEq`, `eqProps` | `===` compares arrays and objects by reference: `eq([], [])` → `false`. For `Ro = [{a:1},…,{a:4}]` and `So = [{a:3},…,{a:6}]`, `union(Ro, So).length` → `8`, `intersection(…)` → `0`, `difference(…)` → `4`. | Structural `==`: `true`, `6`, `2`, `2` | Dafny values have no identity. |
| `keys` | `keys({b: 1, a: 2})` → `['b', 'a']`, in insertion order | `{"a", "b"}`, a `set<string>` | A `map` has no key order. |
| `values` | `values({a: 1, b: 1})` → `[1, 1]`, in key order | `multiset{1, 1}` | A `map` has no key order. |
| `unfoldr` | loops until `fn` returns a falsy value, possibly forever | extra `fuel: nat` parameter; stops after `fuel` elements | Dafny functions must terminate. |
| `compose`/`fog`, `pipe`/`sequence` | variadic: `compose(a, b, c, d)` | binary: `compose(a, compose(b, compose(c, d)))`. There is no unary form; `compose(f)` is `f`. | Dafny functions have fixed arity. |
| `always`, `alwaysZero`, `alwaysFalse`, `alwaysTrue` | ignore however many arguments they get | take exactly one argument of any type (`always(7)(())`) | Fixed arity. |
| `andFn`, `orFn`, `notFn` | forward any number of arguments | unary predicates (pass a tuple) | Fixed arity. |
| `allPredicates`, `anyPredicates` | `allPredicates(preds, v)` applies at once; the result reports the longest predicate's arity | `allPredicates(preds)(v)`; no arity | Fixed arity. |
| `and`, `or`, `not` | coerce operands by truthiness: `and([], "abc")` → `true`, `not("")` → `true` | `bool` operands | Typed. |
| `add`, `subtract`, `multiply`, `sum`, `product`, `lt`, `lte`, `gt`, `gte`, `max`, `min`, `subtractN` | JS numbers (doubles) and coercion: `lt("abc", "xyz")` → `true`, `max([-4.3, -1.1])` → `-1.1` | `int` (`divide`/`divideBy`: `real`) | Typed. |
| `join` | converts elements to strings: `join("~", [1, 2, 3, 4])` → `"1~2~3~4"` | `seq<string>` elements | Typed. |
| `sortBy` | compares keys with JS `<`, so string keys sort: `sortBy(s => s, ["b", "a", "c"])` → `["a", "b", "c"]` | `int` keys | Dafny cannot order arbitrary key types, and overloading by key type is not possible. |
| `sort` | an inconsistent comparator gives an engine-defined order: `sort(() => -1, [1, 2, 3])` → `[3, 2, 1]` | The postconditions say nothing for inconsistent comparators; the implementation (stable insertion sort) gives `[1, 2, 3]`. | ECMAScript leaves it unspecified. |
| string functions | count UTF-16 code units: `charCodeAt(0, "😀")` → `55357`, `"😀".length` → `2` | count code points: `0x1F600`, `1` | A Dafny `string` is a sequence of Unicode scalar values. |
| `toUpperCase`, `toLowerCase` | full Unicode case mapping: `toUpperCase("straße")` → `"STRASSE"`, `toUpperCase("ä")` → `"Ä"` | ASCII letters only: `"STRAßE"`, `"ä"` | Unicode case tables are out of scope. |

## Tests

```
tests/support.dfy   Js (a JS value type for mixed arrays/objects), NumStr
tests/ramda/*.dfy   Ramda's test/test.*.js for the release, transcribed
tests/edge/*.dfy    node-checked edge cases and Deviation* pins
```

The v0.1.0 suite transcribes every `it` in Ramda's 29 test files that the
encoding can express. Each file header lists what it skips: arity checks,
side-effect counting, JS coercion, reference equality, string-keyed
`sortBy`, and the unportable functions' files (`test.lazy.js`, `test.maybe.js`,
`test.partial.js`, `test.wrap.js`, `test.expose.js`).

## Progress

| Ramda release | Date | Status | lem version |
|---|---|---|---|
| v0.1.0 | 2013-12-26 | ported | — |
| v0.1.1 | 2014-05-18 | pending | — |
| v0.1.2 | 2014-05-18 | pending | — |
| v0.1.3 | 2014-06-02 | pending | — |
| v0.1.4 | 2014-06-10 | pending | — |
| v0.1.5 | 2014-06-15 | pending | — |
| v0.2.0 | 2014-06-27 | pending | — |
| v0.2.1 | 2014-06-27 | pending | — |
| v0.2.2 | 2014-06-30 | pending | — |
| v0.2.3 | 2014-07-09 | pending | — |
| v0.2.4 | 2014-07-18 | pending | — |
| v0.3.0 | 2014-08-10 | pending | — |
| v0.4.0 | 2014-08-28 | pending | — |
| v0.4.1 | 2014-08-31 | pending | — |
| v0.4.2 | 2014-09-01 | pending | — |
| v0.4.3 | 2014-09-01 | pending | — |
| v0.5.0 | 2014-09-16 | pending | — |
| v0.6.0 | 2014-10-04 | pending | — |
| v0.7.0 | 2014-10-22 | pending | — |
| v0.7.1 | 2014-10-22 | pending | — |
| v0.7.2 | 2014-10-24 | pending | — |
| v0.8.0 | 2014-11-19 | pending | — |
| v0.9.0 | 2015-01-24 | pending | — |
| v0.9.1 | 2015-01-27 | pending | — |
| v0.10.0 | 2015-02-15 | pending | — |
| v0.11.0 | 2015-03-08 | pending | — |
| v0.12.0 | 2015-03-21 | pending | — |
| v0.13.0 | 2015-03-22 | pending | — |
| v0.14.0 | 2015-05-11 | pending | — |
| v0.15.0 | 2015-06-14 | pending | — |
| v0.15.1 | 2015-06-21 | pending | — |
| v0.16.0 | 2015-07-12 | pending | — |
| v0.17.0 | 2015-07-19 | pending | — |
| v0.17.1 | 2015-07-21 | pending | — |
| v0.18.0 | 2015-10-11 | pending | — |
| v0.19.0 | 2015-12-21 | pending | — |
| v0.19.1 | 2016-01-03 | pending | — |
| v0.20.0 | 2016-03-26 | pending | — |
| v0.20.1 | 2016-03-30 | pending | — |
| v0.21.0 | 2016-04-09 | pending | — |
| v0.22.0 | 2016-08-04 | pending | — |
| v0.22.1 | 2016-08-07 | pending | — |
| v0.23.0 | 2016-12-29 | pending | — |
| v0.24.0 | 2017-05-26 | pending | — |
| v0.24.1 | 2017-06-01 | pending | — |
| v0.25.0 | 2017-10-09 | pending | — |
| v0.26.0 | 2018-11-17 | pending | — |
| v0.26.1 | 2018-11-27 | pending | — |
| v0.27.0 | 2019-05-25 | pending | — |
| v0.27.1 | 2020-07-30 | pending | — |
| v0.27.2 | 2022-01-11 | pending | — |
| v0.28.0 | 2022-01-15 | pending | — |
| v0.29.0 | 2023-04-02 | pending | — |
| v0.29.1 | 2023-10-04 | pending | — |
| v0.30.0 | 2024-04-27 | pending | — |
| v0.30.1 | 2024-06-02 | pending | — |
| v0.31.0 | 2025-06-22 | pending | — |
| v0.31.1 | 2025-06-22 | pending | — |
| v0.31.2 | 2025-06-22 | pending | — |
| v0.31.3 | 2025-06-22 | pending | — |
| v0.32.0 | 2025-10-10 | pending | — |

"—" means not yet published from this history. The un-prefixed
`0.26.0`/`0.26.1` tags duplicate the `v`-prefixed ones and are skipped.

## Release changelog

### v0.1.0 (2013-12-26)

- **Ramda:** the initial release, `ramda.js` only. It has 138 export names
  (121 distinct functions plus 17 aliases): core list primitives, folds,
  map/filter/find, set operations, sorting, object functions, string
  functions, combinators, and arithmetic and logic helpers.
- **Ramdaf:**
  - 116 export names across the nine area modules, plus `Prelude`.
  - The 22 unportable names are in "Not portable".
  - Preconditions are only those in "Outside the modeled domain"; deviations
    are only those in "Deviations".
  - The tests transcribe Ramda's v0.1.0 suite and add node-checked edge cases.
- **lem:** — (not yet published from this history).

## Toolchain

- Dafny 4.10 (lem-pinned) and the Lemmata package manager `lem`.
- `lem test` verifies `src/**/*.dfy`, then builds and runs `tests/**/*.dfy`
  together with it. The equivalent Dafny commands are:

  ```
  dafny verify src/*.dfy
  dafny test src/*.dfy tests/support.dfy tests/ramda/*.dfy tests/edge/*.dfy
  ```
