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
5. Update the "Deviations" and "Not portable" tables, add a "Release
   changelog" entry, and write the release's expected-change manifest
   `casestudy/expected/<tag>.json` (see `casestudy/README.md`).
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
    Functions. `clone`/`cloneDeep` in "Internal Functions and Properties" and
    v0.1.1's "Generators" section (`repeat.nTimes`) go in Core.
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
  - A function stored as a property of another export, `f.p`, is the function
    `fP`: `map.idx` is `mapIdx`, `repeat.nTimes` is `repeatNTimes`.
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
| a documented "no value" result (`find` miss → `undefined`, `nth` out of range → `undefined`, `maxWith([])` → `undefined`) | `Option<T>` |
| `where`'s spec object, whose properties are functions or values | `map<string, Ramdaf.Prelude.SpecVal<V>>`: `Pred(fn)` for a function, `Val(v)` for a value |
| nested arrays (the input of `flatten` and `unnest`) | `Ramdaf.Prelude.Tree<T>`: `Node(children)` for an array, `Leaf(v)` for any other element (an array-like element is not flattened; see "Deviations") |
| a two-element array used as a pair (`zip`'s and `xprod`'s elements, `partition`'s result, `fromPairs`' elements) | `(A, B)` |
| number | `int`, or `real` for `divide`/`divideBy` |
| string | `string` (a sequence of Unicode code points) |
| predicate, "truthy" result | `T -> bool` |
| an index callback, called `fn(x, idx, list)` (`map.idx` and the other `.idx` functions) | `(T, nat, seq<T>) -> R` (folds: `(A, T, nat, seq<T>) -> A`) |
| comparator `(a, b) -> negative/0/positive` | `(T, T) -> int` |
| `===` | `==` (structural; see "Deviations") |
| multi-argument function, auto-curried | an **uncurried** Dafny function with the same parameter order. Dafny cannot partially apply a function, so `f(a)` becomes `x => f(a, x)`. |
| a call with no arguments, `f()` | `f(())` when the function takes one argument of any type |

## Modules and exports (v0.3.0)

| Module | Exports |
|---|---|
| `Ramdaf.Core` | clone, isEmpty, prepend, cons, head, car, first, last, tail, cdr, append, push, concat, identity, I, times, repeatN, size, length |
| `Ramdaf.Functions` | compose, pipe, sequence, flip, fork, distributeTo, always, constant, K, alwaysZero, alwaysFalse, alwaysTrue |
| `Ramdaf.List` | foldl, reduce, foldlIdx (`foldl.idx`), reduceIdx (`reduce.idx`), foldr, reduceRight, foldrIdx (`foldr.idx`), reduceRightIdx (`reduceRight.idx`), unfoldr, mapSeq (`map`), mapIdx (`map.idx`), mapObj, mapObjIdx (`mapObj.idx`), filter, filterIdx (`filter.idx`), reject, rejectIdx (`reject.idx`), takeWhile, take, skipUntil, skip, drop, find, findIndex, findLast, findLastIndex, all, every, any, some, contains, containsWith, uniq, isSet, uniqWith, pluck, flatten, zipWith, zip, xprodWith, xprod, reverse, range, indexOf, indexOfFrom (`indexOf.from`), lastIndexOf, lastIndexOfFrom (`lastIndexOf.from`), join, slice, sliceFrom (`slice.from`), remove, insert, insertAll (`insert.all`), nth, partition, ap, of, empty, chain, flatMap, unnest, flattenShallow, flattenDeep, zipObj, fromPairs |
| `Ramdaf.Sort` | comparator; sort and sortBy by contract (`provides`) |
| `Ramdaf.Object` | eq, prop, get, props, keys, keysIn, values, valuesIn, pick, pickAll, omit, pickWith, mixin, eqProps, where, propEq |
| `Ramdaf.Logic` | and, or, not, allPredicates, anyPredicates |
| `Ramdaf.Math` | add, multiply, subtract, subtractN, divide, divideBy, modulo, moduloBy, mathMod, sum, product, lt, lte, gt, gte, max, maxWith, minWith, min |
| `Ramdaf.String` | substring, substringFrom, substringTo, charAt, charCodeAt, strIndexOf, strLastIndexOf, toUpperCase, toLowerCase, split |
| `Ramdaf.Data` | union, unionWith, difference, differenceWith, intersection, intersectionWith, countBy, groupBy, project |

That is 146 of Ramda v0.3.0's 172 export names, plus 12 of the 14 functions
stored as properties of exports (`map.idx` and the like). The other 26 names
and the 2 properties `each.idx`/`forEach.idx` are listed under "Not portable".

### Support declarations

These are exported but are not Ramda functions:

- `Ramdaf.Prelude` reveals the datatypes `Option`, `Tree` and `SpecVal` from
  the mapping.
- Some modules `provides` an import alias, because an exported signature,
  postcondition or revealed body names that module:
  - `Prelude` in List, Object, Math and Data;
  - `List` in Sort and Data;
  - `Object` in Data.

### Internal Ramda functions

Ramda v0.3.0 does not export `keyValue`, nor its new helpers
`isArrayLike`, `makeFlat`, `checkForMethod` and `isInteger`; they are local
to `ramda.js`, and Ramdaf does not export them either. (`containsWith` was
internal until v0.1.5 exported it, and `uniqWith` until v0.2.0; both are in
List. Until v0.2.3 the `*With` functions in Data carried `uniqWith`'s
recursion themselves; since v0.2.4 they call `List.uniqWith`, as Ramda
does.)

## Not portable

These Ramda v0.3.0 exports are not ported, rather than faked:

| Export | Why |
|---|---|
| `curry` | Ramdaf functions are uncurried, and Dafny has no partial application to curry into. |
| `nAry`, `arity`, `unary`, `binary` | Change a function's reported arity (`fn.length`), which Dafny functions do not have (`unary(fn)` is `nAry(1, fn)`, `binary(fn)` is `nAry(2, fn)`; v0.2.0). |
| `invoker`, `func` | Call a method looked up by name on an object at run time. |
| `useWith` (`disperseTo`) | Variadic argument transformers. (v0.3.0 removed `use(fn).over(...)` and added the alias `disperseTo`.) |
| `lPartial` (`applyLeft`), `rPartial` (`applyRight`) | Variadic partial application. |
| `memoize`, `once` | Rely on hidden mutable state, and `memoize`'s cache is keyed by `String(arg)`. |
| `wrap` | Variadic wrapper (`wrapper(fn, ...arguments)`). |
| `construct` | Calls JS constructors with `new`. |
| `tap` | Its purpose is a side effect (`fn(x)`), which a pure function cannot have. (Until v0.2.4 `K` was an alias of `tap`; v0.3.0 made it an alias of `always`.) |
| `each` (`forEach`), `each.idx` (`forEach.idx`) | Call `fn` on each element for its side effect and return the list itself. |
| `installTo` | Copies the library onto a global or host object. |
| `isAtom` | Tests the run-time type of an arbitrary value. |
| `is` | Tests a value's prototype chain at run time: `is(ctor, val)` is `val != null && Object(val) instanceof ctor` (v0.3.0). (`is` is also a Dafny keyword.) |
| `match` | Regular expressions. |
| `path`, `pathOn` | Walk an arbitrary JS value along a list of property names (v0.2.0; v0.3.0 removed `pathWith`): object properties, array indices (`path('a.e.f.1', obj)` → `101`, Ramda's own test) and string characters, returning whatever value is there (an object, an array or a primitive). The mapping has no type for such a heterogeneous nested value: a `map<string, V>` is homogeneous, and `Tree<T>` has no keys. A nested-object datatype would cover only the object case and leave most of Ramda's `path` tests untranscribable. |

## Outside the modeled domain (preconditions)

| Function | Ramda v0.3.0 (node) | Ramdaf |
|---|---|---|
| `head`, `car`, `first`, `last` | `head([])` → `undefined` (`[]`, the empty list itself, in v0.1.0); `last([])` → `undefined` | `requires \|list\| > 0` |
| `take` | `take(-1, l)` throws `RangeError`. (Before v0.1.5, `take(5, [1, 2])` → `[1, 2, <3 empty items>]`, and Ramdaf required `n <= \|list\|`; v0.1.5 clamps to `[1, 2]`.) | `n: nat` |
| `skip`, `drop` | `skip(-1, [1, 2])` → `[undefined, 1, 2]`; since v0.2.0 `skip(5, [1, 2])` throws `RangeError` (`_slice` allocates `new Array(2 - 5)`; it was `[]`) | `n: nat`, `requires n <= \|list\|` |
| `repeatN`, `times` | `new Array(n)` throws `RangeError` for a negative n: `repeatN(7, -2)` (since v0.2.0; it was `[]`), `times(f, -1)` (v0.2.3) | `n: nat` |
| `remove` | (v0.2.2) `_slice(list, 0, Math.min(start, length))` throws `RangeError` for a negative start (`remove(-1, 1, [1, 2, 3, 4, 5])`), and `_slice(list, start + count)` reads before the start for `start + count < 0` (`remove(2, -5, [1, 2, 3, 4, 5])` → `[1, 2, undefined, undefined, undefined, 1, 2, 3, 4, 5]`) | `requires 0 <= start`, `requires 0 <= start + count` |
| `charCodeAt` | `charCodeAt(10, "abc")` → `NaN` | `requires 0 <= n < \|s\|` |
| `max`, `min` | `max([])` → `-Infinity`, `min([])` → `Infinity` | `requires \|list\| > 0` |
| `divide`, `divideBy` | `divide(1, 0)` → `Infinity` | `requires` a nonzero divisor |
| `modulo`, `moduloBy` | `modulo(1, 0)` → `NaN` | `requires` a nonzero divisor |
| `mathMod` | (v0.3.0) `NaN` unless m is an integer of at least 1 and p an integer: the code tests the dividend, though its documentation names the modulus, so `mathMod(-17, 5)` and `mathMod(0, 5)` → `NaN` (and `mathMod(17, -5)` → `-3`); `mathMod(17, 0)` → `NaN` | `requires 1 <= m`, `requires p != 0` |
| `findLast`, `findLastIndex` | on `[]` the `while (--idx)` loop runs idx through -1, -2, … calling `fn(undefined)` until it is truthy (forever for `x => false`; `findLastIndex(x => x === undefined, [])` → `-1`) | `requires \|list\| > 0` |
| `zipObj` | (v0.3.0) a key without a value gets `undefined` and is still an own property: `zipObj(['a', 'b'], [1])` → `{a: 1, b: undefined}`, whose `Object.keys` are `['a', 'b']` (Ramda's test "extra keys are undefined") | `requires \|keys\| <= \|values\|` |
| `fromPairs` | (v0.3.0) an element that is not an array, or is empty, is skipped (`fromPairs([['a', 1], 'x', [], {}])` → `{a: 1}`); a one-element array gives an `undefined` value (`fromPairs([['a']])` → `{a: undefined}`), and elements past the second are ignored | not expressible: the elements are typed pairs `(string, V)` |
| `where` | a spec or test property whose value is `undefined`: since v0.2.3 `where({x: undefined}, {})` → `true` (it was `false`), `where({x: undefined}, {x: undefined})` → `true`, `where({x: f}, {x: undefined})` calls `f(undefined)`; and `where(spec, null)` → `false` | not expressible: an undefined property is an absent one, and the test object is a `map` |

## Deviations

These are differences on input the encoding can represent. A behavioural
difference is pinned by a `Deviation*` test in `tests/edge/`; a difference in
a signature (an arity or an operand type) is enforced by the types.

| Function(s) | Ramda v0.3.0 (node) | Ramdaf | Why |
|---|---|---|---|
| `eq`, `contains`, `indexOf`, `lastIndexOf`, `uniq`, `isSet`, `union`, `difference`, `intersection`, `propEq`, `eqProps`, `where` (value entries) | `===` compares arrays and objects by reference: `eq([], [])` → `false`. For `Ro = [{a:1},…,{a:4}]` and `So = [{a:3},…,{a:6}]`, `union(Ro, So).length` → `8`, `intersection(…)` → `0`, `difference(…)` → `4`. | Structural `==`: `true`, `6`, `2`, `2` | Dafny values have no identity. |
| `keys`, `keysIn` | `keys({b: 1, a: 2})` → `['b', 'a']`, in insertion order | `{"a", "b"}`, a `set<string>` | A `map` has no key order. |
| `values`, `valuesIn` | `values({a: 1, b: 1})` → `[1, 1]`, in key order | `multiset{1, 1}` | A `map` has no key order. |
| `unfoldr` | loops until `fn` returns a falsy value, possibly forever | extra `fuel: nat` parameter; stops after `fuel` elements | Dafny functions must terminate. |
| `compose`, `pipe`/`sequence` | variadic: `compose(a, b, c, d)` | binary: `compose(a, compose(b, compose(c, d)))`. There is no unary form; `compose(f)` is `f`. | Dafny functions have fixed arity. |
| `always`, `constant`, `K`, `alwaysZero`, `alwaysFalse`, `alwaysTrue` | ignore however many arguments they get | take exactly one argument of any type (`always(7)(())`) | Fixed arity. |
| `and`, `or`, `not`, `fork`, `distributeTo` | forward any number of arguments | unary functions (pass a tuple) | Fixed arity. |
| `fork`, `distributeTo` | takes any number of functions after `after`: `fork(after, f1, f2, f3)` | exactly two, `fork(after, f1, f2)` | Fixed arity. |
| `of` | `of(x, container)` dispatches to `container.of(x)` (Fantasy-land) and ignores any other container: `of(1, [9])` → `[1]` | `of(x)`: no container parameter | Fixed arity; no Dafny value has an `of` method. |
| `mapIdx`, `filterIdx`, `rejectIdx`, `foldlIdx`/`reduceIdx`, `foldrIdx`/`reduceRightIdx` | call `fn(x, idx, list)` (folds: `fn(acc, x, idx, list)`), and a function that declares fewer parameters ignores the rest: `map.idx(times2, l)` | the callback takes all three (four) | Fixed arity. |
| `allPredicates`, `anyPredicates` | `allPredicates(preds, v)` applies at once; the result reports the longest predicate's arity | `allPredicates(preds)(v)`; no arity | Fixed arity. |
| `add`, `subtract`, `multiply`, `sum`, `product`, `lt`, `lte`, `gt`, `gte`, `max`, `min`, `subtractN`, `modulo`, `moduloBy`, `mathMod` | JS numbers (doubles) and coercion: `lt("abc", "xyz")` → `true`, `max([-4.3, -1.1])` → `-1.1` | `int` (`divide`/`divideBy`: `real`) | Typed. |
| `groupBy` | uses whatever `fn` returns as a key, converted to a string: `groupBy(x => x > 2, [1, 3])` → `{false: [1], true: [3]}` (`partition` did so from v0.1.4 to v0.2.4) | `fn: T -> string` | Typed. |
| `join` | converts elements to strings: `join("~", [1, 2, 3, 4])` → `"1~2~3~4"` | `seq<string>` elements | Typed. |
| `zipObj`, `fromPairs` | convert keys to strings: `zipObj([1, 2], ['x', 'y'])` → `{"1": 'x', "2": 'y'}` | `string` keys | Typed. |
| `empty` | takes any argument: `empty(5)`, `empty({})` and `empty()` → `[]` | `empty(x: seq<T>): seq<T>` | Typed: the result's element type comes from the argument. |
| `chain`, `flatMap` | keep a result of `f` that is not array-like as one element: `chain(x => x * 2, [1, 2])` → `[2, 4]`, `chain(x => 'ab', [1, 2])` → `['ab', 'ab']` | `f: A -> seq<B>`; a string result is a sequence of characters and is concatenated: `chain(x => "ab", [1, 2]) == "abab"` | Typed; a Dafny `string` is a `seq<char>`. |
| `flatten`, `flattenDeep`, `unnest`, `flattenShallow` | since v0.3.0 flatten every array-like element (`isArrayLike`: an object with a numeric `length`, or a function, whose `length` is its arity; never a string): `flatten([{length: 0}])` → `[]`, `flatten([{length: 2, 0: 'a', 1: 'b'}])` → `['a', 'b']`, `flatten([x => x])` → `[undefined]` | only a `Node` is flattened: `flatten([Leaf(map["length" := 0])])` is `[map["length" := 0]]` | `Tree<T>` marks nesting by constructor. |
| `groupBy`, `countBy`, `zipObj`, `fromPairs` | a key that names an `Object.prototype` member is not an ordinary property: `groupBy(x => 'hasOwnProperty', [1])` → `{hasOwnProperty: [undefined, 1]}`, `countBy(x => '__proto__', [1, 2])` → `{}`, `zipObj(['__proto__', 'a'], [1, 2])` → `{a: 2}`, and `groupBy(x => '__proto__', [1, 2])` throws `RangeError` (`groupBy` and `countBy` did all this before v0.3.0 as well) | every key is ordinary: `map["hasOwnProperty" := [1]]`, `map["__proto__" := 2]`, `map["__proto__" := 1, "a" := 2]`; the throw is not modeled | A `map` has no prototype. |
| `sortBy`, `maxWith`, `minWith` | compare keys with JS `<`/`>`, so string keys work: `sortBy(s => s, ["b", "a", "c"])` → `["a", "b", "c"]` | `int` keys | Dafny cannot order arbitrary key types, and overloading by key type is not possible. |
| `sort` | an inconsistent comparator gives an engine-defined order: `sort(() => -1, [1, 2, 3])` → `[3, 2, 1]` | The postconditions say nothing for inconsistent comparators; the implementation (stable insertion sort) gives `[1, 2, 3]`. | ECMAScript leaves it unspecified. |
| string functions | count UTF-16 code units: `charCodeAt(0, "😀")` → `55357`, `"😀".length` → `2` | count code points: `0x1F600`, `1` | A Dafny `string` is a sequence of Unicode scalar values. |
| `toUpperCase`, `toLowerCase` | full Unicode case mapping: `toUpperCase("straße")` → `"STRASSE"`, `toUpperCase("ä")` → `"Ä"` | ASCII letters only: `"STRAßE"`, `"ä"` | Unicode case tables are out of scope. |

## Tests

```
tests/support.dfy   Js (a JS value type for mixed arrays/objects), NumStr, Truthy
tests/ramda/*.dfy   Ramda's test/test.*.js for the release, transcribed
tests/edge/*.dfy    node-checked edge cases and Deviation* pins
```

The suite transcribes every `it` in the release's Ramda test files that the
encoding can express. Each file header lists what it skips: arity checks,
side-effect counting, JS coercion, reference equality, method dispatch on
non-array objects, array-like objects, string-keyed `sortBy`, and the
unportable functions' files (`test.each.js`, `test.maybe.js`,
`test.partial.js`, `test.wrap.js`, `test.expose.js`, `test.curry.js`,
`test.path.js`, `test.is.js`).

## Progress

| Ramda release | Date | Status | lem version |
|---|---|---|---|
| v0.1.0 | 2013-12-26 | ported | — |
| v0.1.1 | 2014-05-18 | ported | — |
| v0.1.2 | 2014-05-18 | ported | — |
| v0.1.3 | 2014-06-02 | ported | — |
| v0.1.4 | 2014-06-10 | ported | — |
| v0.1.5 | 2014-06-15 | ported | — |
| v0.2.0 | 2014-06-27 | ported | — |
| v0.2.1 | 2014-06-27 | ported | — |
| v0.2.2 | 2014-06-30 | ported | — |
| v0.2.3 | 2014-07-09 | ported | — |
| v0.2.4 | 2014-07-18 | ported | — |
| v0.3.0 | 2014-08-10 | ported | — |
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

### v0.1.1 (2014-05-18)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - `foldr`/`reduceRight` call `fn(acc, x)` instead of `fn(x, acc)`; `foldr1`,
    which delegates to `foldr`, follows (`foldr1(f, [a, b, c])` is
    `f(f(c, b), a)`, was `f(a, f(b, c))`).
  - `intersection` is now `uniq(filter(flip(contains)(list1), list2))`: its
    elements and their order come from the second list
    (`intersection([1, 2, 3, 4], [4, 3, 2])` → `[4, 3, 2]`, was `[2, 3, 4]`).
  - The `fog` alias of `compose` is gone.
  - New: `findIndex`, `findLast`, `findLastIndex` (their `while (--idx)` loop
    never tests index 0, and never ends on `[]`), `isSet`, `mixin`, `where`
    (function and value spec entries), `modulo`, `moduloBy`, `cloneDeep`,
    `repeat` (a generator) with `repeat.nTimes`, `each`/`forEach`, and the
    index variants `map.idx`, `filter.idx`, `reject.idx`, `foldl.idx`
    (= `reduce.idx`), `foldr.idx` (= `reduceRight.idx`), `each.idx`.
  - "No value" sentinels changed outside the modeled domain: `find` miss
    `false` → `undefined`, `nth` out of range `null` → `undefined`,
    `maxWith`/`minWith` of `[]` `undefined` → `null`, `head([])` `[]` →
    `undefined`. The set functions became curried, and `filter` calls a
    predicate that returned false a second time with `(x, idx, list)`; neither
    is visible to a unary Dafny predicate.
- **Ramdaf:**
  - `foldr`/`reduceRight` take `fn: (A, B) -> A`; `foldr1` follows;
    `intersection` filters `list2`; `fog` is removed.
  - Added `findIndex`, `findLast`, `findLastIndex` (index 0 skipped; the empty
    list is outside their domain), `isSet`, `mixin`, `where` (with the new
    `Prelude.SpecVal`), `modulo`/`moduloBy` (JS truncated remainder),
    `cloneDeep` (`T(==)`), `repeatNTimes`, `mapIdx`, `filterIdx`, `rejectIdx`,
    `foldlIdx`/`reduceIdx`, `foldrIdx`/`reduceRightIdx`.
  - Not ported: `each`/`forEach` (+ `.idx`) and `repeat` ("Not portable").
  - New deviation: `cloneDeep` keeps `undefined` properties that JSON drops.
  - Tests: the v0.1.1 changes to test.core.js, test.clone.js, test.fold.js
    (whose foldl1/foldr1 describes Ramda dropped), test.filter.js,
    test.find.js, test.map.js, test.containsuniq.js, test.math.js,
    test.objectBasics.js, test.product.js and test.lazy.js's `repeat.nTimes`.
- **Expected tier: major.** `foldr` and `reduceRight` changed signature,
  `foldr1` and `intersection` changed meaning, and `fog` was removed
  (`casestudy/expected/v0.1.1.json`).
- **lem:** — (not yet published from this history).

### v0.1.2 (2014-05-18)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - New: `fork(f1, f2, after)`, which returns a function that applies `f1`
    and `f2` to its arguments and passes both results to `after` (not
    curried).
  - `range` sizes its result array `Math.floor(to) - Math.ceil(from)` instead
    of `to - from`. The values are unchanged; float bounds that used to throw
    "Invalid array length" now work (`range(0.5, 3)` → `[0.5, 1.5, 2.5]`).
    Integer ranges are identical.
  - Generators gained `takeWhile`, and `R.takeWhile` dispatches to it.
- **Ramdaf:** added `fork` (unary result; see "Deviations"). `range` is over
  `int` and generators are not portable, so nothing else changes. Tests: the
  `fork` describe of test.compose.js; test.lazy.js's generator `takeWhile` is
  not portable.
- **Expected tier: patch.** The only change is an addition (`fork`).
  Conventional semver would call that minor; `lem` treats pure additions as
  patch by design (`casestudy/expected/v0.1.2.json`).
- **lem:** — (not yet published from this history).

### v0.1.3 (2014-06-02)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - `generator`, `repeat` and `repeat.nTimes` are removed; the generator code
    moves to `ext/lazylist`, outside `ramda.js`.
  - New: `repeatN(value, n)`, a loop that builds n copies and returns `[]`
    for `n <= 0` (`repeatN(7, -2)` → `[]`, where `repeat.nTimes(7, -1)`
    overflowed the stack).
  - `tail`, `foldl`, `foldr`, `map`, `filter`, `takeWhile`, `take` and `skip`
    dispatch to a method of the same name on any non-array object instead of
    checking `length === Infinity`. Arrays are unaffected.
- **Ramdaf:** `repeatNTimes` is removed and `repeatN(value, n: int)` added in
  Core (an `int` count, since negative counts are now defined). `generator`
  and `repeat` leave "Not portable", and `repeatNTimes`'s precondition row
  leaves "Outside the modeled domain". Tests: test.list.js's new `repeatN`
  describe replaces test.lazy.js's `repeat.nTimes`, which left `test/`.
- **Expected tier: major.** `repeatNTimes` (Ramda's `repeat.nTimes`) was
  removed (`casestudy/expected/v0.1.3.json`).
- **lem:** — (not yet published from this history).

### v0.1.4 (2014-06-10)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - The boolean operators `and`, `or` and `not` are deleted, and the
    predicate combinators `andFn`, `orFn` and `notFn` are renamed to `and`,
    `or` and `not` (`and(true, false)` was `false`; now `and(f, g)` returns a
    predicate).
  - `fork` takes `after` first and any number of functions:
    `fork(after, f1, ..., fn)`.
  - New: `first` (an alias of `head`), `last`, `mapObj`, `partition`
    (groups a list by the string key a function returns, like `groupBy`;
    Ramda's test groups students by grade), `slice(from, to, list)` and
    `slice.from(from, list)` (`Array.prototype.slice`).
  - `maybe` is removed.
  - `indexOf`, `lastIndexOf` and `join` become `invoker`s over
    `Array.prototype`; on arrays their results are unchanged (checked in
    node).
- **Ramdaf:**
  - `and`, `or`, `not` take and return predicates (`T -> bool`); `andFn`,
    `orFn`, `notFn` are removed.
  - `fork(after, f1, f2)`: exactly two functions ("Deviations").
  - Added `first`, `last` (non-empty lists), `mapObj`, `slice`, `sliceFrom`
    and `partition(fn: T -> string, list)` in List, where `ramda.js` defines
    them.
  - `maybe` leaves "Not portable"; the boolean-coercion deviation row goes
    with the boolean operators.
  - Tests: the rewritten test.booleans.js, the reordered `fork` test,
    test.core.js's `last`, test.list.js's `slice`/`slice.from`, test.map.js's
    `mapObj`, and the new test.partition.js.
- **Expected tier: major.** `and`, `or`, `not` and `fork` changed signature,
  and `andFn`, `orFn`, `notFn` were removed (`casestudy/expected/v0.1.4.json`).
- **lem:** — (not yet published from this history).

### v0.1.5 (2014-06-15)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - `take` sets the copy's length to `Math.min(n, list.length)`:
    `take(5, [1, 2])` → `[1, 2]` (it had three empty slots).
  - `containsWith` is exported.
  - `where` is rewritten: a value entry must be an *own* property of the test
    object (`where({x: undefined}, {})` → `false`, was `true`), a null-ish
    test object gives `false` (it threw), function entries are checked before
    value entries, and `where(spec)` is curried by hand. Function and value
    entries, and `where(spec)` returning a predicate, already existed in
    v0.1.1.
  - `nAry` and `arity` pre-fill their wrapper cache (not portable).
- **Ramdaf:**
  - `take` drops its `n <= |list|` precondition and clamps.
  - `containsWith` is exported from List, where `ramda.js` defines it.
  - `where` is unchanged: its value entries already require the property
    (`k in test`), and the other v0.1.5 cases (an undefined spec value, a null
    test object) cannot be written in this encoding ("Outside the modeled
    domain").
  - Tests: test.objectBasics.js's new curried `where` case (its null-ish and
    undefined-property cases cannot be written); `take` and `containsWith`
    edge cases.
- **Expected tier: patch.** `take`'s precondition was weakened with every
  previous result unchanged (compatible), and `containsWith` was added.
  Conventional semver would call that minor; `lem` treats such changes as
  patch (`casestudy/expected/v0.1.5.json`).
- **lem:** — (not yet published from this history).

### v0.2.0 (2014-06-27)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - Most functions are now curried by hand (`arguments.length < 2 ? … : …`),
    and a new private `_slice(args, from, to)` copies into
    `new Array(to - from)`, reading `from || 0` and `to || args.length`. It
    backs `clone`, `skip`, `takeWhile`, `skipUntil` and `splice`, with these
    observable effects:
    - `takeWhile` returns the whole list when the first element fails the
      predicate (`takeWhile(x => x > 5, [1, 2, 3])` → `[1, 2, 3]`, was `[]`);
    - `skip`/`drop` throw `RangeError` for n > length (`skip(5, [1, 2])`, was
      `[]`);
    - `splice` is `_slice(list, 0, start).concat(_slice(list, start + len))`
      instead of `Array.prototype.splice`: `splice(0, 2, [1, 2, 3, 4, 5])` →
      `[1, 2, 3, 4, 5, 3, 4, 5]` (was `[3, 4, 5]`), and a negative start or
      `start + len > length` throws `RangeError` (both were clamped).
  - `repeatN` allocates `new Array(n)`, so a negative n throws `RangeError`
    (was `[]`).
  - `sum` and `product` (`foldl(add, 0)`, `foldl(multiply, 1)`) share one
    accumulator across calls (`sum([1, 2, 3])` → `6`, then `12`); v0.2.2
    fixes it.
  - Removed: `cloneDeep`, `foldl1`, `foldr1`.
  - New: `constant` (an alias of `always`), `keysIn` and `valuesIn` (with
    prototype properties), `path`, `pathOn`, `pathWith`, `unary`, `binary`;
    `uniqWith` is exported.
  - `groupBy` becomes an alias of `partition`. Both group by the string key
    `fn` returns, so `groupBy`'s results are unchanged.
  - `findIndex`/`findLastIndex` return `-1` on a miss (was `undefined`).
  - `maxWith`/`minWith` take a key function instead of a comparator
    (`maxWith(prop('x'), list)`, Ramda's test): the first element with the
    greatest (least) key wins, and `[]` gives `undefined` (was `null`).
  - `zip`/`zipWith` stop at the shorter list (they read `undefined` past the
    end of the second).
  - Not visible in this encoding: `filter` no longer calls a failing
    predicate a second time with `(x, idx, list)`; `compose()` with no
    functions returns `undefined`; `allPredicates`/`anyPredicates` share one
    implementation; `max`/`min` fold with `Math.max`/`Math.min`.
- **Ramdaf:**
  - Removed `cloneDeep` (Core), `foldl1` and `foldr1` (List), with their
    "Outside the modeled domain" rows and `cloneDeep`'s deviation.
  - Added `constant` (Functions), `keysIn`/`valuesIn` (Object; a map has no
    prototype, so they are `keys`/`values`) and `uniqWith` (List; it keeps
    the last representative, the recursion the Data `*With` functions already
    carry).
  - `groupBy` (Data) is now `List.partition(fn, list)`; its results are
    unchanged.
  - `findIndex`/`findLastIndex` return `int`, `-1` on a miss.
  - `maxWith`/`minWith` take `keyFn: T -> int` (int keys, as for `sortBy`).
  - `zip`/`zipWith` drop their `|a| <= |b|` precondition and stop at the
    shorter list.
  - The `_slice` behaviour is reproduced: `takeWhile` returns the whole list
    when the first element fails; `splice` follows `_slice`, with
    `0 <= start <= |list|` and `0 <= start + len <= |list|` required;
    `skip`/`drop` require `n <= |list|`; `repeatN` takes `n: nat`.
  - "Not portable" gains `unary`, `binary`, `path`, `pathOn` and `pathWith`.
  - New deviation: `sum` and `product` keep no state between calls.
  - Tests: the v0.2.0 changes to test.always.js (`constant`), test.clone.js
    (`cloneDeep` gone), test.core.js (array elements in `prepend`/`append`),
    test.filter.js (`takeWhile`/`skipUntil` with `undefined`), test.find.js
    (`-1`, the new `findLast` describe), test.keysvals.js (`keysIn`,
    `valuesIn`; the prototype cases cannot be written), test.math.js
    (`maxWith`/`minWith` by key) and test.zip.js (the shorter list); the
    path describes and test.functionBasics.js's `unary`/`binary` test
    unportable functions. Edge cases cover the `_slice` behaviour,
    `uniqWith`, `maxWith`/`minWith` and `zip`.
- **Expected tier: major.** `cloneDeep`, `foldl1` and `foldr1` were removed;
  `findIndex`, `findLastIndex`, `maxWith`, `minWith` and `repeatN` changed
  signature; `takeWhile` and `splice` changed results; `skip`, `drop` and
  `splice` gained preconditions (`casestudy/expected/v0.2.0.json`).
- **lem:** — (not yet published from this history).

### v0.2.1 (2014-06-27)

- **Ramda:** packaging only. The logo files leave the repository (and
  `bower.json` ignores `logo`), the README's logo credit is reworded, and
  `package.json`'s version is bumped. `ramda.js` and `test/` are
  byte-identical to v0.2.0.
- **Ramdaf:** no source or test change; this entry and the manifest only.
- **Expected tier: patch.** Nothing changed (`casestudy/expected/v0.2.1.json`,
  with no changes).
- **lem:** — (not yet published from this history).

### v0.2.2 (2014-06-30)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - Private `curry2`/`curry3` wrappers replace v0.2.0's hand currying
    (calling a curried function with no arguments now throws), and `curry`
    takes an optional arity. A side effect: `foldl` no longer keeps its
    accumulator between calls, so `sum` and `product` are pure again (a new
    test, "does not save the state of the accumulator").
  - `splice` is removed. New: `remove(start, count, list)`,
    `insert(index, elt, list)` and `insert.all(index, elts, list)`, all built
    on `_slice`. `insert` appends at the end when the index is outside
    `[0, length)`. A cut at index 0 reads `_slice(list, 0, 0)` as the whole
    list: `insert(0, 9, [1, 2, 3])` → `[1, 2, 3, 9, 1, 2, 3]`,
    `remove(0, 2, [1, 2, 3, 4, 5])` → `[1, 2, 3, 4, 5, 3, 4, 5]` (Ramda's own
    tests use other indices). `remove` with a negative start throws
    `RangeError`.
  - New: `mapObj.idx` (`fn(value, key, obj)`), `indexOf.from(target,
    fromIdx, list)` and `lastIndexOf.from(target, fromIdx, list)` (a negative
    fromIdx counts from the end). `indexOf`/`lastIndexOf` are reimplemented
    without `Array.prototype` (same results on arrays).
  - `flatten`, `path`, `pathOn` and `pathWith` are reimplemented; `flatten`'s
    results are unchanged (the path functions are not portable).
- **Ramdaf:**
  - Removed `splice` and its precondition row.
  - Added `remove` (with `0 <= start` and `0 <= start + count` required),
    `insert` and `insertAll`, reproducing `_slice`'s index-0 behaviour; and
    `mapObjIdx`, `indexOfFrom`, `lastIndexOfFrom` (List, next to the
    functions they extend).
  - The `sum`/`product` deviation is gone: node now agrees with the port.
  - Tests: test.list.js's rewrite (`remove`, `insert`, `insert.all`; the
    `splice`, `indexOf` and `lastIndexOf` describes left), the new
    test.indexof.js, test.map.js's `mapObj.idx`, test.math.js's accumulator
    test, test.allany.js's curried cases and test.flatten.js's flat list (its
    reference and million-empty-slot cases cannot be written); test.curry.js
    and test.path.js test unportable functions. Edge cases cover the index-0
    behaviour, negative counts and the `.from` variants.
- **Expected tier: major.** `splice` was removed
  (`casestudy/expected/v0.2.2.json`).
- **lem:** — (not yet published from this history).

### v0.2.3 (2014-07-09)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - New: `times(fn, n)` (`[fn(0), …, fn(n - 1)]`; a negative n throws
    `RangeError`), and `pickWith(test, obj)`, the own properties for which
    `test(value, key, obj)` is truthy. `pick`, `omit` and `repeatN` are
    rewritten on top of them with unchanged results.
  - `where` is rewritten. A function entry whose property the test object
    does not own now fails without calling the function: `where({a: x => x
    === undefined}, {})` → `false` (was `true`). A value entry compares
    `spec[key] !== testObj[key]` without checking ownership, which changes
    only undefined-valued spec properties (`where({x: undefined}, {})` →
    `true`, was `false`; outside the modeled domain).
  - `keys` uses `Object.keys` and `values` goes through `keys`, so an object
    with its own `hasOwnProperty` property no longer throws
    (`keys({hasOwnProperty: false})` → `['hasOwnProperty']`; up to v0.2.2
    `keys`, `values`, `pick`, `omit`, `mixin` and `where` threw a
    `TypeError` there).
  - `compose`/`pipe` with a single function return a partially applied
    `compose`/`pipe`, and pass `this` through (the binary port is
    unaffected); `curry`'s `toString`/`source` decoration is gone.
- **Ramdaf:**
  - Added `times` (Core, `fn: nat -> T`, `n: nat`) and `pickWith` (Object).
  - `where`'s function entries require the property:
    `Pred(fn) => k in test && fn(Some(test[k]), test)`. `SpecVal`'s function
    type is unchanged; the function now never receives `None`.
  - The `hasOwnProperty` throw was never modeled: a map's keys never throw,
    so the earlier ports did not document that input as outside their domain
    (an omission in v0.1.0 to v0.2.2), and nothing changes now.
  - Tests: test.list.js's `times`, test.objectBasics.js's `pickWith` (its
    reference-inequality case cannot be written), test.keysvals.js's
    `hasOwnProperty` cases (its primitive-argument cases cannot be written),
    test.range.js's `from > to`, test.compose.js's multi-argument first
    function (as a tuple; the `this` cases are not portable), and
    test.fold.js's reworded `foldr.idx` case. Edge cases cover `where`'s
    absent properties, `pickWith`'s arguments and `times`.
- **Expected tier: major.** `where` changed results for a function entry on
  an absent property; `times` and `pickWith` were added
  (`casestudy/expected/v0.2.3.json`).
- **lem:** — (not yet published from this history).

### v0.2.4 (2014-07-18)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; most of the
  diff is new JSDoc comments, and the code changes are these):
  - `merge` is removed. `concat`, its alias since v0.1.x, is now its own
    function and dispatches to a `concat` method of a non-array first
    argument (`concat('foo', 'bar')` → `'foobar'`); on arrays its results are
    unchanged.
  - `uniq` and `uniqWith` keep the FIRST occurrence (class representative)
    instead of the last, with new tests "keeps elements from the left":
    `uniq([1, 2, 1, 3, 2])` → `[1, 2, 3]` (was `[1, 3, 2]`). `uniqWith` keeps
    an item unless `pred(item, kept)` holds for an element already kept
    (`uniqWith((a, b) => a < b, [1, 2, 3])` → `[1, 2, 3]`, was `[3]`).
  - Through them `union`, `unionWith`, `difference`, `differenceWith`,
    `intersection` and `intersectionWith` change their results
    (`difference([1, 2, 1, 3], [])` → `[1, 2, 3]`, was `[2, 1, 3]`).
  - `_slice` reads `from`/`to` only when they are numbers, so an end index of
    0 is no longer "the end": `takeWhile(x => x > 5, [1, 2, 3])` → `[]` (was
    `[1, 2, 3]`), `insert(0, 9, [1, 2, 3])` → `[9, 1, 2, 3]`,
    `remove(0, 2, [1, 2, 3, 4, 5])` → `[3, 4, 5]`, and `insert.all` alike
    (new test "returns the appropriate sublist when start == 0").
    `skip` past the end and `remove` with a negative start still throw.
  - `isSet`, `mixin` and `installTo` are reimplemented with unchanged
    results; `where` tests `key in testObj`, which also accepts inherited
    properties (no counterpart for a map).
- **Ramdaf:**
  - Removed `merge`; `concat` is `list1 + list2` (same results).
  - `uniq` and `uniqWith` keep the first occurrence and call
    `pred(item, kept)`; their bodies recurse on all but the last element, as
    the loop does.
  - The Data `*With` functions are now `List.uniqWith` of the combined or
    filtered list, as in Ramda; `union`, `difference` and `intersection`
    follow `List.uniq`. The `*With` postconditions now say
    `!pred(later, earlier)`.
  - `takeWhile`, `remove`, `insert` and `insertAll` drop the index-0
    behaviour.
  - Tests: test.containsuniq.js's "keeps elements from the left" and the new
    `uniqWith` describe (its `alwaysTrue`/`alwaysFalse` markers are strings
    here), test.core.js's `concat` (the object-with-a-`concat`-method case is
    not portable), test.list.js's `remove` at 0, and test.objectBasics.js's
    new `where` and `mixin` cases (the prototype ones cannot be written);
    the edge cases switch to first occurrences and the fixed index 0.
- **Expected tier: major.** `merge` was removed, and `uniq`, `uniqWith`,
  `union`, `unionWith`, `difference`, `differenceWith`, `intersection`,
  `intersectionWith`, `takeWhile`, `remove`, `insert` and `insertAll`
  changed results (`casestudy/expected/v0.2.4.json`).
- **lem:** — (not yet published from this history).

### v0.3.0 (2014-08-10)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; most of the
  diff is new JSDoc and names for anonymous functions, and the code changes
  are these):
  - `partition` becomes a split by a predicate, "like its Haskell
    namesake": `partition(pred, list)` returns `[passing, failing]`, reading
    `pred`'s result for truthiness (`partition(x => x % 2, [0, 1, 2, 3])` →
    `[[1, 3], [0, 2]]`, was `{0: [0, 2], 1: [1, 3]}`). Its key-grouping body
    becomes `groupBy`'s, which was an alias of `partition` since v0.2.0;
    `groupBy`'s results are unchanged, each group in list order.
  - New: `ap(fns, vs)` (every function over every value, the functions
    outermost), `of(x)` (`[x]`), `empty(x)` (`[]`), `chain(f, list)`
    (`unnest(map(f, list))`) with the alias `flatMap`, `unnest` (one level of
    `flatten`) with the alias `flattenShallow`, `zipObj(keys, values)` and
    `fromPairs(pairs)` (a later duplicate key wins), `mathMod(m, p)`
    (`((m % p) + p) % p`, `NaN` unless m is an integer of at least 1 and p a
    nonzero integer: the code tests the dividend, against its documentation,
    so `mathMod(-17, 5)` is `NaN` and `mathMod(17, -5)` is `-3`), `is`, and
    the aliases `length` (`size`), `flattenDeep` (`flatten`), `distributeTo`
    (`fork`) and `disperseTo` (`useWith`). `ap`, `of`, `empty` and `chain`
    dispatch to Fantasy-land methods of non-array arguments.
  - `K` moves from `tap` to `always`: `K(5, f)` was `5`; `K(5)` is now a
    function that returns `5`.
  - `nth` becomes an alias of `prop` (`obj[p]`), which on a list is the
    same lookup: its results are unchanged.
  - `flatten` is `makeFlat(true)`, which flattens every array-like element,
    not only arrays: `flatten([{length: 0}])` → `[]` (was `[{length: 0}]`).
    Arrays give the same results.
  - Removed: `use` (`useWith` and its new alias `disperseTo` remain) and
    `pathWith`.
  - Not visible in this encoding: `curry2`/`curry3` replace the remaining
    hand currying (a call with no arguments now throws); `compose()` throws,
    `compose(f)` is `f`, and a composition reports its rightmost function's
    arity; `checkForMethod` replaces the in-body method dispatch, so
    `pluck`, `reject` and `reject.idx` no longer dispatch to a non-array's
    `map`/`filter`; `take` is rewritten on `_slice` with the same results;
    `where` sorts its spec with `groupBy` instead of `partition`.
- **Ramdaf:**
  - `partition(pred: T -> bool, list)` returns the pair
    `(filter(pred, list), reject(pred, list))`. `groupBy` (Data) takes over
    partition's old body and postconditions instead of calling it.
  - Added `length` (Core, next to `size`), `K` and `distributeTo`
    (Functions, with `always` and `fork`), `ap`, `of`, `empty`, `chain`,
    `flatMap`, `unnest`, `flattenShallow`, `flattenDeep`, `zipObj` and
    `fromPairs` (List), and `mathMod` (Math). `unnest` uses the `Tree`
    encoding, like `flatten`; `chain` takes `f: A -> seq<B>`; `empty` is
    `seq<T> -> seq<T>`; `of` has no `container` parameter.
  - `nth` keeps its own body (`prop` takes a map); `nth`, `flatten` and
    `compose` change only in their comments.
  - "Not portable": `use`, `pathWith` and `K` leave; `is` and `disperseTo`
    join.
  - "Outside the modeled domain" gains `mathMod` (`1 <= m`, `p != 0`),
    `zipObj` (no more keys than values) and `fromPairs` (untyped elements,
    not expressible). The mapping gains a pair row, and the `Tree` row says
    only an array is a `Node`.
  - New deviations: `of` (no container), `empty`, `chain`/`flatMap` (a
    string result is concatenated), keys converted to strings in `zipObj` and
    `fromPairs`, array-like elements in `flatten`/`unnest` (a `Leaf` is never
    flattened), and keys that name `Object.prototype` members in `groupBy`,
    `countBy`, `zipObj` and `fromPairs` (for `groupBy` and `countBy` an
    omission of the earlier ports). The always-family and `fork` rows gain
    `K` and `distributeTo` (and the overlooked `constant`), the int row
    `mathMod`.
  - Tests: the rewritten test.partition.js (with a `Truthy` helper in
    `tests/support.dfy` for `partition(Boolean)`), the new test.groupBy.js
    (partition's old tests, retargeted), test.core.js's `length`,
    test.list.js's `of`, `empty` and `chain`, test.flatten.js's `unnest`,
    test.functionBasics.js's `ap`, test.math.js's `mathMod` and test.zip.js's
    `zipObj` and `fromPairs`. Not transcribed: compose's arity, no-argument
    and one-argument cases, the array-like and method-dispatch cases,
    `zipObj`'s extra keys, `fromPairs`' skipped elements, `mathMod`'s
    non-integer and `NaN` cases, and test.is.js. The old partition edge
    cases move to `groupBy`; new edge cases cover the new functions, with
    `Deviation*` pins for array-like leaves, string results of `chain` and
    prototype-named keys.
- **Expected tier: major.** `partition` changed signature and meaning;
  `groupBy`'s revealed body was rewritten with the same results
  (compatible); 14 names were added (`casestudy/expected/v0.3.0.json`).
- **lem:** — (not yet published from this history).

## Toolchain

- Dafny 4.10 (lem-pinned) and the Lemmata package manager `lem`.
- `lem test` verifies `src/**/*.dfy`, then builds and runs `tests/**/*.dfy`
  together with it. The equivalent Dafny commands are:

  ```
  dafny verify src/*.dfy
  dafny test src/*.dfy tests/support.dfy tests/ramda/*.dfy tests/edge/*.dfy
  ```
