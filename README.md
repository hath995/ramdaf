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
2. Diff the library source (`ramda.js` until v0.8.0; from v0.9.0 one
   `src/<fn>.js` per export, plus `src/internal/`) and `test/` against the
   previous tag.
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
  - Up to v0.8.0 a new function goes in the area of the `ramda.js` section
    that defines it: "Core Functions" → Core, "Function functions" → Functions, "List
    Functions" → List, "Object Functions" → Object, "Logic Functions" → Logic,
    "Arithmetic Functions" → Math, "String Functions" → String, "Data
    Analysis and Grouping Functions" → Data, and "Miscellaneous Functions" →
    Functions. `clone`/`cloneDeep` in "Internal Functions and Properties" and
    v0.1.1's "Generators" section (`repeat.nTimes`) go in Core.
  - From v0.9.0, which splits `ramda.js` into one file per export, a new
    function (a renamed one included) goes in the area of its JSDoc
    `@category`: Function → Functions, List → List, Object → Object, Logic →
    Logic, Math → Math, String → String, Relation → Data and Type → Core. So
    `repeat` (v0.9.0) is in List, where `repeatN`, which it renames, was in
    Core.
  - There are established exceptions: sorting goes in Sort (`comparator`,
    `sort`, `sortBy`); the `always` family goes in Functions; `size` (until
    v0.8.0) and `length` are in Core; `propEq` is in Object; `flip` stays in Functions although v0.8.0
    moves it among the internal functions.
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
  - Ramda's `map` is `mapSeq`, because `map` is a Dafny keyword. Likewise
    Ramda's `if` (v0.8.0 only) was `if_`, and a lens's `set` and `map`
    properties are the fields `set_` and `map_`.
  - Until v0.8.0 a function stored as a property of another export, `f.p`,
    was the function `fP`: `map.idx` was `mapIdx`, `repeat.nTimes`
    `repeatNTimes`. v0.9.0 has no such properties: it renamed the `.idx`
    functions to `*Indexed` exports (removals and additions here) and
    `insert.all` to `insertAll`, the name the port already used.
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
    tag's `ramda.js`, or from v0.9.0 its `dist/ramda.js`).
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
| a property that is absent or `undefined` | `None` of `Ramdaf.Prelude.Option<V>`. `None` also stands for `null` where a value is tested for being "nil": `isNil` (v0.9.0) takes an `Option`, and so does `defaultTo` (v0.10.0) for the value it defaults, so it composes with the "no value" results below (see "Deviations") |
| a documented "no value" result (`find` miss → `undefined`, `maxBy([])` → `undefined`, `nth` out of range → `undefined` (until v0.4.1 removed `nth`, and again since v0.8.0), `cond` when no predicate matches → `undefined` (v0.8.0)) | `Option<T>` |
| `where`'s spec object, whose properties are functions or values | `map<string, Ramdaf.Prelude.SpecVal<V>>`: `Pred(fn)` for a function, `Val(v)` for a value |
| nested arrays (the input of `flatten` and `unnest`) | `Ramdaf.Prelude.Tree<T>`: `Node(children)` for an array, `Leaf(v)` for any other element (an array-like element is not flattened; see "Deviations") |
| a two-element array used as a pair (`zip`'s and `xprod`'s elements, `partition`'s result, `fromPairs`' elements, `cond`'s `[predicate, transformer]` arguments, the `[accumulator, element]` arrays of `mapAccum` and `mapAccumRight` (`mapAccumL` and `mapAccumR` in v0.9.x) and their results) | `(A, B)` |
| a bound lens, `lensOn`'s result (v0.11.0): a function `l` of no arguments with the properties `l.set` and `l.map` | `Ramdaf.Prelude.LensOn<V, B>`, a record of partial arrows (`-->`), as for a lens: `l.get()` for the call `l()`, `l.set_(v)` for `l.set(v)` and `l.map_(fn)` for `l.map(fn)`, which requires `l.get`'s and then `l.set_`'s preconditions (see "Deviations") |
| a lens, `lens`'s result (v0.8.0): a function `l` with the properties `l.set` and `l.map` | `Ramdaf.Prelude.Lens<A, V>`, a record of partial arrows (`-->`): `l.get(a)` for the call `l(a)`, `l.set_(v, a)` for `l.set(v, a)` and `l.map_(fn, a)` for `l.map(fn, a)`; a getter or setter that throws or is `undefined` on part of its domain has a precondition there, and `l.map_` requires `l.get`'s and then `l.set_`'s (see "Deviations") |
| number | `int`, or `real` for `divide` |
| string | `string` (a sequence of Unicode code points) |
| predicate, "truthy" result | `T -> bool` |
| an index callback, called `fn(x, idx, list)` (`mapIndexed` and the other `*Indexed` functions, the `.idx` properties until v0.8.0) | `(T, nat, seq<T>) -> R` (folds: `(A, T, nat, seq<T>) -> A`) |
| comparator `(a, b) -> negative/0/positive` | `(T, T) -> int` |
| `===` | `==` (structural; see "Deviations") |
| multi-argument function, auto-curried | an **uncurried** Dafny function with the same parameter order. Dafny cannot partially apply a function, so `f(a)` becomes `x => f(a, x)`. For the `op` functions (`subtract`, `divide`, `modulo`, `mathMod`, `lt`, `lte`, `gt`, `gte`), `f(a)` is `x => f(a, x)` too, and `f(R.__, b)` (the placeholder, since v0.6.0; a non-enumerable `undefined` until v0.8.0, the exported object `{ramda: 'placeholder'}` since v0.9.0, which also curries `concat` and `contains` this way, and since v0.10.0 `merge`) is `x => f(x, b)`. (In v0.5.0 alone, `f(a)` was `x => f(x, a)` and `f(a, R._)` was `x => f(a, x)`.) Since v0.11.0 `op` is gone and every curried function takes the placeholder in any position: `f(R.__, b)` is still `x => f(x, b)`, while `f(R.__)` is `f` itself, so `subtract(R.__)(5)` is `x => 5 - x` (from v0.6.0 to v0.10.0 `op` made it `x => x - 5`). |
| a call with no arguments, `f()` | `f(())` when the function takes one argument of any type. (Since v0.11.0 a curried Ramda function called with no arguments returns itself, `identity()` is `identity`; the functions Ramda returns, such as `always(7)`, `T` and `cond(…)`'s result, are not curried, and they are the ones called this way.) |

## Modules and exports (v0.11.0)

| Module | Exports |
|---|---|
| `Ramdaf.Core` | clone, isEmpty, prepend, prependTo, nth, head, last, tail, append, appendTo, concat, identity, I, times, length, isNil |
| `Ramdaf.Functions` | compose, pipe, flip, converge, always, T, F |
| `Ramdaf.List` | reduce, reduceIndexed, reduceRight, reduceRightIndexed, unfold, mapSeq (`map`), mapIndexed, mapObj, mapObjIndexed, filter, filterIndexed, reject, rejectIndexed, takeWhile, take, dropWhile, drop, find, findIndex, findLast, findLastIndex, all, any, contains, containsWith, uniq, isSet, uniqWith, pluck, flatten, zipWith, zip, lens, xprod, reverse, range, indexOf, lastIndexOf, join, slice, remove, insert, insertAll, partition, ap, of, empty, chain, commuteMap, commute, unnest, zipObj, fromPairs, scan, createMapEntry, repeat, init, mapAccum, mapAccumRight, mergeAll |
| `Ramdaf.Sort` | comparator; sort and sortBy by contract (`provides`) |
| `Ramdaf.Object` | eq, prop, get, propOf, props, propOr, has, hasIn, keys, keysIn, toPairs, toPairsIn, values, valuesIn, pick, pickAll, omit, pickBy, merge, eqProps, where, assoc, propEq, evolve, invert, invertObj, dissoc, lensOn |
| `Ramdaf.Logic` | and, or, not, allPass, anyPass, ifElse, cond, defaultTo |
| `Ramdaf.Math` | add, multiply, subtract, divide, modulo, mathMod, sum, product, lt, lte, gt, gte, max, maxBy, minBy, min, inc, dec, negate |
| `Ramdaf.String` | substring, substringFrom, substringTo, charAt, charCodeAt, strIndexOf, strLastIndexOf, toUpper, toLower, trim, replace, split |
| `Ramdaf.Data` | union, unionWith, difference, differenceWith, intersection, intersectionWith, countBy, groupBy, project, eqDeep |

That is 163 of Ramda v0.11.0's 203 export names (since v0.9.0 Ramda has no
functions stored as properties of exports). The other 40 names are listed
under "Not portable".

### Support declarations

These are exported but are not Ramda functions:

- `Ramdaf.Prelude` reveals the datatypes `Option`, `Tree`, `SpecVal`,
  `Lens` (v0.8.0) and `LensOn` (v0.11.0) from the mapping.
- Some modules `provides` an import alias, because an exported signature,
  postcondition or revealed body names that module:
  - `Prelude` in Core, List, Object, Logic, Math and Data (Core for `nth`
    and, since v0.9.0, `isNil`, and Logic for `cond`, since v0.8.0, and
    `defaultTo`, since v0.10.0);
  - `List` in Sort and Data;
  - `Object` in Data.

### Internal Ramda functions

Ramda v0.11.0 does not export the helpers `_makeFlat`, `_checkForMethod` and
`_isInteger` (v0.3.0) or `_pairWith` and
`_functionsWith` (v0.4.0, behind `toPairs`/`toPairsIn` and
`functions`/`functionsIn`); v0.8.0 gave every private helper a `_` prefix
and added more, such as `_baseCopy` (behind `clone` since v0.9.0),
`_pCompose`, `_prepend`/`_append`, `_map`, `_filter`, `_pickBy` and
`_pickAll`, and v0.9.0 adds `_all`, `_any`, `_ap`, `_eqDeep`,
`_filterIndexed`, `_foldl`, `_forEach`, `_gt`, `_lt`, `_nth` and `_pluck`
(v0.9.1 deletes `_keyValue`, `keyValue` until v0.7.2, and `_compareKeys`,
with which `countBy` and `sortBy` were written; v0.10.0 renames `_foldl` to
`_reduce` and `_pCompose` to `_composeP`; v0.11.0 deletes `_pickBy` and
`_noArgsException` and adds `_curry1`, `_has`, `_assoc`, `_dissoc`,
`_assocPath` and `_dissocPath`).
Since v0.9.0 they are the modules `src/internal/_*.js` (until v0.8.0 local
to `ramda.js`), and Ramdaf does not export them either. (`isArrayLike`, private since v0.3.0, is exported in v0.5.0 and is
not portable.) (`containsWith` was
internal until v0.1.5 exported it, and `uniqWith` until v0.2.0; both are in
List. Until v0.2.3 the `*With` functions in Data carried `uniqWith`'s
recursion themselves; since v0.2.4 they call `List.uniqWith`, as Ramda
does.)

## Not portable

These Ramda v0.11.0 exports are not ported, rather than faked:

| Export | Why |
|---|---|
| `curry`, `curryN` | Ramdaf functions are uncurried, and Dafny has no partial application to curry into. (v0.5.0 moved `curry`'s arity argument to the new `curryN(n, fn)`.) |
| `__` | The currying placeholder, the object `{ramda: 'placeholder'}` (exported since v0.9.0; until v0.8.0 a non-enumerable `undefined`). Since v0.11.0 every curried function accepts it in any argument position (`subtract(R.__, 5)`, `has(R.__, obj)`). Until v0.10.0 it served `op` (v0.5.0), which v0.11.0 removed: `op(fn)` made a binary function from one with exactly two parameters (v0.6.0; before, at least two); in v0.5.0 its one-argument call fixed the second parameter, with the placeholder `R._` for the first, and from v0.6.0 one argument fixed the first parameter and the placeholder as the first argument the second (v0.9.0 curried `concat` and `contains`, and v0.10.0 `merge`, the same way). The uncurried port has no partial application (see the mapping). (`version`, the release string from v0.5.0 to v0.8.0, was listed here as release metadata until v0.9.0 removed it.) |
| `nAry`, `arity`, `unary`, `binary` | Change a function's reported arity (`fn.length`), which Dafny functions do not have (`unary(fn)` is `nAry(1, fn)`, `binary(fn)` is `nAry(2, fn)`; v0.2.0). |
| `invoker`, `func` | Call a JS method on an object at run time: `func` looks it up by name, and so, since v0.8.0, does `invokerN(n, 'name', ...args)`, which calls the last argument's own method `name` and which v0.9.0 renames `invoker` (from v0.6.0 to v0.7.2 `invoker(method)` and `invokerN(n, method)` took the method itself; until v0.5.0 `invoker` took a name and a prototype; v0.8.0 removed that `invoker`). |
| `bind` | Fixes the `this` of a JS function (v0.6.0; since v0.11.0 the result keeps `fn`'s arity); Dafny functions have no `this`. |
| `useWith` | Variadic argument transformers. (v0.3.0 removed `use(fn).over(...)` and added the alias `disperseTo`, which v0.4.1 removed.) |
| `partial`, `partialRight` | Variadic partial application. (v0.4.1 removed their aliases `applyLeft` and `applyRight`; v0.10.0 renamed `lPartial` and `rPartial` to `partial` and `partialRight`.) |
| `memoize`, `once` | Rely on hidden mutable state, and `memoize`'s cache is keyed by each argument's string and type tag (`42::[object Number]`; since v0.10.0, `String(arg)` before), which no generic Dafny function can compute. |
| `wrap` | Variadic wrapper (`wrapper(fn, ...arguments)`). |
| `apply`, `unapply`, `nthArg`, `call` | Variadic. `apply` spreads a list of run-time length into a function's positional arguments, `fn.apply(this, args)` (v0.7.0), and passes `this`; `unapply(fn)` (v0.8.0), its inverse, collects any number of arguments into one list for `fn` (`unapply(JSON.stringify)(1, 2, 3)` → `'[1,2,3]'`; a Dafny `unapply(fn: seq<A> -> B)` would be `fn` itself); `nthArg(n)` (`argN` in v0.8.0) returns a function of any number of arguments that returns the nth (`nthArg(1)('a', 'b')` → `'b'`; since v0.9.0 a negative n counts from the end); `call(fn, ...args)` (v0.9.0) is `fn.apply(this, args)`. |
| `composeP`, `pipeP` | Promise-aware composition (v0.8.0; `pCompose` and `pPipe` until v0.9.1): each intermediate result is tested at run time for a `then` method, and a promise's value is passed on inside `then`, asynchronously. Dafny has no promises or run-time type tests, and without them `pCompose` would be `compose`. |
| `lift`, `liftN` | Lift a function of a run-time arity over lists (v0.7.0): `liftN(n, fn)` takes n lists, and `lift(fn)` reads `fn.length`. Dafny functions have no run-time arity. |
| `construct`, `constructN` | Call JS constructors with `new` (`constructN(n, Fn)`, v0.4.0, also fixes the result's reported arity at n, and since v0.10.0 takes at most 10 arguments; `construct(Fn)` is `constructN(Fn.length, Fn)`). |
| `tap` | Its purpose is a side effect (`fn(x)`), which a pure function cannot have. (Until v0.2.4 `K` was an alias of `tap`; v0.3.0 made it an alias of `always`. v0.7.0 reversed the arguments to `tap(fn, x)`.) |
| `forEach`, `forEachIndexed` | Call `fn` on each element for its side effect and return the list itself. (Until v0.4.0 the definitions were `each` and `each.idx`, with `forEach` as the alias; v0.4.1 removed `each`; v0.9.0 renamed `forEach.idx` to `forEachIndexed`.) |
| `installTo` | Copies the library onto a global or host object (`@deprecated since v0.11.0`). |
| `isArrayLike`, `type` | Test the run-time type of an arbitrary value: v0.5.0 exports `isArrayLike`, the predicate behind `flatten`, whose rule v0.7.2 narrows to objects owning their extreme indices (v0.5.0 also removed `isAtom`, which was here for the same reason); `type(val)` (v0.8.0) names the type (`'Null'`, `'Undefined'`, or `Object.prototype.toString`'s tag such as `'Object'`, `'Number'` or `'Array'`), which a generic Dafny function cannot inspect. |
| `is` | Tests a value's constructor and prototype chain at run time: `is(ctor, val)` is `val != null && val.constructor === ctor \|\| val instanceof ctor` (v0.4.0; v0.3.0 had `val != null && Object(val) instanceof ctor`). (`is` is also a Dafny keyword.) |
| `functions`, `functionsIn` | List the property names whose values are functions (`typeof obj[key] === 'function'`; `functionsIn` includes inherited ones; v0.4.0): a run-time type test on each value, which a `map<string, V>` of one value type cannot make. |
| `match` | Regular expressions. |
| `path`, `pathEq`, `assocPath`, `dissocPath` | Walk an arbitrary JS value along a list of property names (v0.2.0; v0.3.0 removed `pathWith`; `pathEq(path, val, obj)`, v0.7.0, compares what `path` finds; `assocPath(path, val, obj)`, v0.8.0, copies every object on the way and sets the last property, replacing a value that is not an object with `{}`; `dissocPath(path, obj)`, v0.11.0, copies every object on the way and deletes the last property, turning arrays, strings and other primitives on the way into objects: `dissocPath(['a', 'b'], {a: 'str'})` → `{a: {0: 's', 1: 't', 2: 'r'}}`. Until v0.10.0 the path was a dot-separated string, and `pathOn(sep, str, obj)`, removed in v0.11.0, split it on any separator): object properties, array indices (`path(['a', 'e', 'f', '1'], obj)` → `101`, Ramda's own test) and string characters, returning whatever value is there (an object, an array or a primitive). The mapping has no type for such a heterogeneous nested value: a `map<string, V>` is homogeneous, and `Tree<T>` has no keys. A nested-object datatype would cover only the object case and leave most of Ramda's `path` tests untranscribable. |

## Outside the modeled domain (preconditions)

| Function | Ramda v0.11.0 (node) | Ramdaf |
|---|---|---|
| `head`, `last` | `head([])` → `undefined` (`[]`, the empty list itself, in v0.1.0); `last([])` → `undefined` (since v0.8.0 they are `nth(0)` and `nth(-1)`; `car`, an alias of `head` until v0.8.0, shared the row) | `requires \|list\| > 0` |
| `drop` (`skip` until v0.8.0) | `drop(-1, [1, 2])` → `[undefined, 1, 2]`. (From v0.2.0 to v0.4.3 `skip(5, [1, 2])` threw `RangeError`, as `_slice` allocated `new Array(2 - 5)`, and Ramdaf required `n <= \|list\|`; since v0.5.0 it is `[]`, as it was before v0.2.0.) | `n: nat` |
| `repeat` (`repeatN` until v0.8.0), `times` | `new Array(n)` throws `RangeError` for a negative n: `repeat(7, -2)` (since v0.2.0; it was `[]`), `times(f, -1)` (v0.2.3) | `n: nat` |
| `remove` | (v0.2.2) `_slice(list, start + count)` reads before the start for `start + count < 0` (`remove(2, -5, [1, 2, 3, 4, 5])` → `[1, 2, undefined, undefined, undefined, 1, 2, 3, 4, 5]`, `remove(-2, 1, [1, 2, 3, 4, 5])` → `[undefined, 1, 2, 3, 4, 5]`). (Until v0.7.2 `_slice(list, 0, Math.min(start, length))` also threw `RangeError` for a negative start, as in `remove(-1, 1, [1, 2, 3, 4, 5])`, and Ramdaf required `0 <= start`; since v0.8.0 that cut is empty.) | `requires 0 <= start + count` |
| `charCodeAt` | `charCodeAt(10, "abc")` → `NaN` | `requires 0 <= n < \|s\|` |
| `differenceWith` | (v0.11.0) `out[idx] = first[idx]` writes each kept element at its own index, leaving a hole at every dropped index before the last kept one: `differenceWith(eq, [1, 2, 3, 4], [2])` → `[1, <hole>, 3, 4]` (length 4; `JSON.stringify` gives `[1,null,3,4]`), `differenceWith(eq, [1, 1, 2], [])` → `[1, <hole>, 2]`; later elements are compared with the holes, as `undefined`. Ramda's own tests keep a prefix. (v0.7.0 to v0.10.0 pushed, with no holes.) | `requires` that the kept elements are a prefix of `first`: once one element is dropped (against `second` or the elements kept before it), every later one is dropped against `second` or that prefix |
| `max`, `min` | `max([])` → `-Infinity`, `min([])` → `Infinity` | `requires \|list\| > 0` |
| `divide` | `divide(1, 0)` → `Infinity` | `requires` a nonzero divisor |
| `modulo` | `modulo(1, 0)` → `NaN` | `requires` a nonzero divisor |
| `mathMod` | (v0.4.2) `NaN` unless m and p are integers and p is at least 1: `mathMod(17, -5)` and `mathMod(17, 0)` → `NaN`. (v0.3.0 to v0.4.1 tested the dividend instead, against the documentation: `mathMod(-17, 5)` and `mathMod(0, 5)` were `NaN` and `mathMod(17, -5)` was `-3`, and Ramdaf required `1 <= m` and `p != 0`.) | `requires p >= 1` |
| `zipObj` | (v0.3.0) a key without a value gets `undefined` and is still an own property: `zipObj(['a', 'b'], [1])` → `{a: 1, b: undefined}`, whose `Object.keys` are `['a', 'b']` (Ramda's test "extra keys are undefined") | `requires \|keys\| <= \|values\|` |
| `fromPairs` | (v0.3.0) an element that is not an array, or is empty, is skipped (`fromPairs([['a', 1], 'x', [], {}])` → `{a: 1}`); a one-element array gives an `undefined` value (`fromPairs([['a']])` → `{a: undefined}`), and elements past the second are ignored | not expressible: the elements are typed pairs `(string, V)` |
| `invertObj` | (v0.9.0) for a repeated value the key last in property order wins: `invertObj({b: 'v', a: 'v'})` → `{v: 'a'}`, `invertObj({a: 'v', b: 'v'})` → `{v: 'b'}` (Ramda's test "prefers the last key found…"), and a map has no property order | `requires` distinct values |
| `where` | a spec or test property whose value is `undefined`: since v0.2.3 `where({x: undefined}, {})` → `true` (it was `false`), `where({x: undefined}, {x: undefined})` → `true`, `where({x: f}, {x: undefined})` calls `f(undefined)`; and `where(spec, null)` → `false` | not expressible: an undefined property is an absent one, and the test object is a `map` |

## Deviations

These are differences on input the encoding can represent. A behavioural
difference is pinned by a `Deviation*` test in `tests/edge/`; a difference in
a signature (an arity or an operand type) is enforced by the types.

| Function(s) | Ramda v0.11.0 (node) | Ramdaf | Why |
|---|---|---|---|
| `eq`, `contains`, `indexOf`, `lastIndexOf`, `uniq`, `isSet`, `union`, `difference`, `intersection`, `propEq`, `eqProps`, `where` (value entries) | `===` compares arrays and objects by reference: `eq([], [])` → `false`. For `Ro = [{a:1},…,{a:4}]` and `So = [{a:3},…,{a:6}]`, `union(Ro, So).length` → `8`, `intersection(…)` → `0`, `difference(…)` → `4`. | Structural `==`: `true`, `6`, `2`, `2` | Dafny values have no identity. |
| `keys`, `keysIn`, `toPairs`, `toPairsIn`, `invert` | `keys({b: 1, a: 2})` → `['b', 'a']` and `toPairs({b: 1, a: 2})` → `[['b', 1], ['a', 2]]`, in insertion order, and `invert({b: 'v', a: 'v'})` (v0.9.0) → `{v: ['b', 'a']}` | `{"a", "b"}`, `{("a", 2), ("b", 1)}` and `map["v" := {"a", "b"}]`, sets | A `map` has no key order. |
| `values`, `valuesIn` | `values({a: 1, b: 1})` → `[1, 1]`, in key order | `multiset{1, 1}` | A `map` has no key order. |
| `unfold` (`unfoldr` until v0.9.1) | loops until `fn` returns a falsy value, possibly forever | extra `fuel: nat` parameter; stops after `fuel` elements | Dafny functions must terminate. |
| `compose`, `pipe` | variadic: `compose(a, b, c, d)` | binary: `compose(a, compose(b, compose(c, d)))`. There is no unary form; `compose(f)` and `pipe(f)` give `f`'s results in node too (since v0.11.0 through a wrapper with `f`'s arity; `f` itself from v0.3.0 and v0.4.0 to v0.10.0). | Dafny functions have fixed arity. |
| `always`, `T`, `F` (`alwaysTrue`, `alwaysFalse` and `alwaysZero` until v0.8.0) | ignore however many arguments they get | take exactly one argument of any type (`always(7)(())`) | Fixed arity. |
| `and`, `or`, `not`, `converge`, `ifElse` (and its alias `if_` in v0.8.0), `cond` | forward any number of arguments | unary functions (pass a tuple) | Fixed arity. |
| `cond` | takes its `[predicate, transformer]` pairs as separate arguments, any number of them (v0.8.0): `cond([p1, t1], [p2, t2])` | one `seq` of pairs: `cond([(p1, t1), (p2, t2)])` | Fixed arity. |
| `converge` (`fork` until v0.4.1) | takes any number of functions after `after`: `converge(after, f1, f2, f3)` (its v0.4.2 documentation names three); since v0.11.0 it is `curryN(3, …)`, so `converge(after, f)` waits for another function (`converge(a => [a], x => x + 1)(5)` is a function) | exactly two, `converge(after, f1, f2)` | Fixed arity. |
| `mapIndexed`, `filterIndexed`, `rejectIndexed`, `reduceIndexed`, `reduceRightIndexed` (`foldlIndexed` and `foldrIndexed` in v0.9.x, the `.idx` properties until v0.8.0) | call `fn(x, idx, list)` (folds: `fn(acc, x, idx, list)`), and a function that declares fewer parameters ignores the rest: `mapIndexed(times2, l)` | the callback takes all three (four) | Fixed arity. |
| `allPass`, `anyPass` (`allPredicates`, `anyPredicates` until v0.8.0) | `allPass(preds, v)` applies at once; the result reports the longest predicate's arity | `allPass(preds)(v)`; no arity | Fixed arity. |
| `allPass`, `anyPass` | since v0.9.0 the one-argument form of an empty list throws, as the result's arity is `max([])`, `-Infinity`: `allPass([])` and `anyPass([])` → `Error: First argument to arity must be a non-negative integer no greater than ten`, while `allPass([], 5)` → `true` and `anyPass([], 5)` → `false` | `allPass([])(5) == true`, `anyPass([])(5) == false`: the two-argument values | The port has no reported arity; the two-argument form defines the value. |
| `add`, `subtract`, `multiply`, `sum`, `product`, `lt`, `lte`, `gt`, `gte`, `max`, `min`, `modulo`, `mathMod`, `inc`, `dec`, `negate` | JS numbers (doubles) and coercion: `lt("abc", "xyz")` → `true`, `max([-4.3, -1.1])` → `-1.1`, `inc('1')` (v0.9.0) → `'11'` | `int` (`divide`: `real`) | Typed. |
| `eq`, `eqDeep` | since v0.9.0 `eq` is `Object.is` (`_eqDeep` compares with it too): `-0` differs from `0` and `NaN` equals itself, and JS arithmetic on representable input makes `-0`: `eq(negate(0), 0)`, `eq(multiply(-1, 0), 0)`, `eq(modulo(-4, 2), 0)` and `eqDeep([negate(0)], [0])` → `false` (all `true` in v0.8.0) | `true`: an `int` has no `-0` | Typed: doubles are `int` here. (`contains`, `indexOf`, `uniq`, `propEq`, `eqProps` and `where` still use `===`, which agrees.) |
| `isNil`, `defaultTo` | test any value for `null` or `undefined`: `isNil(null)` and `isNil(undefined)` → `true`, `isNil(0)`, `isNil('')`, `isNil([])` → `false` (v0.9.0); `defaultTo(d, v)` (v0.10.0) is `v == null ? d : v`, and the default and the value may differ in type: `defaultTo(42, null)` → `42`, `defaultTo(42, 'a real value')` → `'a real value'` | take an `Option<T>`: `isNil(None) == true`, `isNil(Some(v)) == false`, `defaultTo<T>(d: T, v: Option<T>): T` (`defaultTo(d, None) == d`, `defaultTo(d, Some(v)) == v`); `None`, the port's `undefined`, stands for `null` too | Typed: a Dafny value is never `null`, and one `T` cannot hold both a value and `null` (nor a default of another type). |
| `groupBy` | uses whatever `fn` returns as a key, converted to a string: `groupBy(x => x > 2, [1, 3])` → `{false: [1], true: [3]}` (`partition` did so from v0.1.4 to v0.2.4) | `fn: T -> string` | Typed. |
| `and`, `or` | since v0.7.0 return the deciding operand, `f(x) && g(x)` (`\|\|`), not a boolean: `or(x => 0, x => 'b')(1)` → `'b'` (was `true`), so `or(prop('a'), always('d'))` is a default-value combinator | `T -> bool` predicates and a `bool` result | Typed. |
| `replace` | the pattern may be a RegExp (`replace(/\d+/g, 'num', '1 2 three')` → `'num num three'`, every match with the `g` flag) and the replacement a function (`replace('a', x => x.toUpperCase(), 'banana')` → `'bAnana'`); other values are converted to strings (`replace(1, 'x', 'a1b')` → `'axb'`) | string pattern and replacement only | Typed; regular expressions are not portable (as for `match`). |
| `join` | converts elements to strings: `join("~", [1, 2, 3, 4])` → `"1~2~3~4"` | `seq<string>` elements | Typed. |
| `zipObj`, `fromPairs`, `createMapEntry`, `assoc`, `invert`, `invertObj` | convert keys to strings: `zipObj([1, 2], ['x', 'y'])` → `{"1": 'x', "2": 'y'}`, `createMapEntry(1, 'x')` and `assoc(1, 'x', {})` (v0.8.0) → `{"1": 'x'}`, and `invert({a: 1, b: 1})` (v0.9.0) → `{"1": ['a', 'b']}` (the values become keys) | `string` keys (and `string` values for `invert` and `invertObj`) | Typed. |
| `empty` | takes any argument: `empty(5)`, `empty({})` and `empty()` → `[]` | `empty(x: seq<T>): seq<T>` | Typed: the result's element type comes from the argument. |
| `chain` | keeps a result of `f` that is not array-like as one element: `chain(x => x * 2, [1, 2])` → `[2, 4]`, `chain(x => 'ab', [1, 2])` → `['ab', 'ab']` | `f: A -> seq<B>`; a string result is a sequence of characters and is concatenated: `chain(x => "ab", [1, 2]) == "abab"` | Typed; a Dafny `string` is a `seq<char>`. |
| `commute`, `commuteMap` | work on a Fantasy-land functor, with `of` building the result's functor (v0.8.0; the documentation points at `Maybe` and `Either`); since v0.9.0 the private `_map` and `_ap` call only the `ap` method of `of`'s result, so a functor's `map` is no longer used | arrays only: `fn: seq<A> -> seq<B>`, `of: seq<B> -> seq<seq<B>>` | Typed; no Dafny value has methods. |
| `lensOn` | returns a function with properties (v0.11.0): `l()` is `get(obj)` and ignores its arguments, `l.set` is the given `set` itself, passing every argument, and `l.map(fn)` is `set(fn(get(obj)))`, where `fn` may return a value of another type; `get` runs on each call, so a later mutation of `obj` shows | a `Prelude.LensOn` record of partial arrows: `l.get()`, `l.set_(v)`, `l.map_(fn)`, with `fn: V -> V` and `set_: V --> B` | A Dafny function value has no properties (and `set` and `map` are keywords); typed; a Dafny value does not change. |
| `lens` | returns a function with properties (v0.8.0): `l(a)` is `get(a)`, and `l.set(v, a)` and `l.map(fn, a)` (curried since v0.9.0) are properties of `l`; `fn` may return a value of another type | a `Prelude.Lens` record of partial arrows: `l.get(a)`, `l.set_(v, a)`, `l.map_(fn, a)`, with `fn: V -> V` | A Dafny function value has no properties (and `set` and `map` are keywords); typed. |
| `flatten`, `unnest` | since v0.3.0 flatten every array-like element. Since v0.7.2 that is an array, an `arguments` object, or another object (not a `String`) whose `length` is 0, or is positive with own properties `0` and `length - 1`, or (with `nodeType === 1`) is truthy: `flatten([{length: 0}])` → `[]`, `flatten([{length: 2, 0: 'a', 1: 'b'}])` → `['a', 'b']`, `flatten([{nodeType: 1, length: -1}])` → `[]`. (v0.3.0 also counted a function, whose `length` is its arity, until v0.4.0; and v0.3.0 to v0.7.1 counted any object with a numeric `length` of at least 0, so `flatten([{length: 2}])` was `[undefined, undefined]`, where node and the port now agree on `[{length: 2}]`.) | only a `Node` is flattened: `flatten([Leaf(map["length" := 0])])` is `[map["length" := 0]]` | `Tree<T>` marks nesting by constructor. |
| `groupBy`, `countBy`, `zipObj`, `fromPairs`, `createMapEntry`, `clone`, `merge`, `mergeAll`, `assoc`, `evolve`, `invert`, `invertObj`, `dissoc` | a key that names an `Object.prototype` member is not an ordinary property: `groupBy(x => 'hasOwnProperty', [1])` → `{hasOwnProperty: [undefined, 1]}`, `countBy(x => '__proto__', [1, 2])` → `{}` (since v0.9.1 `countBy` counts every other member name as an ordinary key; until v0.9.0 `countBy(x => 'hasOwnProperty', [1, 2])` → `'function hasOwnProperty() { [native code] }11'`), `zipObj(['__proto__', 'a'], [1, 2])` → `{a: 2}`, `createMapEntry('__proto__', 1)` (v0.7.0) has no own key, the keys of `assoc('__proto__', 1, {a: 1})` (v0.8.0) are `['a']` (since v0.11.0 `assoc` and `dissoc` copy with a `for…in` loop, and an object value then becomes the result's prototype), `invertObj({a: '__proto__', b: 'c'})` (v0.9.0) → `{c: 'b'}`, `evolve({toString: x => typeof x}, {})` (v0.9.0) passes the inherited member (→ `{toString: 'function'}`), `invert({a: '__proto__', b: 'x'})` (v0.10.0) → `{x: ['b']}`, its prototype set to `['a']` (in v0.9.x it and any other of the 12 names threw `TypeError: out[val].push is not a function`; since v0.10.0 the others are ordinary keys, as here), and `groupBy(x => '__proto__', [1, 2])` throws `RangeError` (`groupBy` and `countBy` did all this before v0.3.0 as well). Every function that copies properties by assignment drops an own `__proto__` property, which only `JSON.parse` or `Object.defineProperty` can create: `clone` (`cloneObj` from v0.5.0 and `cloneDeep` in v0.8.0, which v0.9.0 merged into it) and `merge` (`mixin` until v0.9.1) of `JSON.parse('{"__proto__": 5, "a": 1}')` → `{a: 1}`, and `mapObj`, `mapObjIndexed`, `pick`, `pickAll`, `pickBy`, `omit`, `assoc` (v0.8.0), `evolve` (v0.9.0), `mergeAll` and `dissoc` (v0.10.0) and `project` likewise; and `sort` (since v0.9.0, an omission of that port), which sorts deep copies of the elements, drops it from each element object (`Object.keys(sort(() => 0, [<that object>])[0])` → `['a']`; `sortBy` did so in v0.9.1 alone, and since v0.10.0 sorts a shallow copy, as here) | every key is ordinary (`evolve` passes `None` for a key that obj lacks): `map["hasOwnProperty" := [1]]`, `map["__proto__" := 2]`, `map["__proto__" := 1, "a" := 2]`, and the copies keep `"__proto__"`; the throw is not modeled | A `map` has no prototype. |
| `sortBy`, `maxBy`, `minBy` | compare keys with JS `<`/`>`, so string keys work: `sortBy(s => s, ["b", "a", "c"])` → `["a", "b", "c"]` | `int` keys | Dafny cannot order arbitrary key types, and overloading by key type is not possible. |
| `evolve` | a transformation may return a value of another type: `evolve({wow: String}, {})` (v0.9.0) → `{wow: 'undefined'}` | `transformations: map<string, Option<V> -> V>`, one value type | Typed. |
| `sort` | `clone(list).sort(…)` (since v0.9.0) deep-copies the list and returns a JS string as it is, so a string throws: `sort((a, b) => a < b ? -1 : a > b ? 1 : 0, 'cab')` → `TypeError: clone(...).sort is not a function` (`['a', 'b', 'c']` until v0.8.0; `sortBy` threw likewise in v0.9.1 alone, and since v0.10.0 sorts `_slice(list)`, so `sortBy(c => c.charCodeAt(0), 'cba')` → `['a', 'b', 'c']`, as here) | `sort(cmp, "cab") == "abc"`: a `string` is a `seq<char>` | A precondition on the generic `sort` cannot single out the string case. |
| `sort`, `sortBy` | `Array.prototype.sort` puts `undefined` elements last without calling the comparator: `sortBy(x => x === undefined ? -1 : x, [1, undefined, 0])` → `[0, 1, undefined]` (since v0.9.1, which sorts the elements rather than key/value pairs, and still since v0.10.0's `_slice` copy; v0.9.0 gave `[undefined, 0, 1]`), and `sort` with the same key comparison → `[0, 1, undefined]` (always; an omission of the earlier ports) | `Undefined` is ordered like any other element: `[Undefined, Num(0), Num(1)]` with the key -1 | A generic `T` has no `undefined` to single out. |
| `sort` | an inconsistent comparator gives an engine-defined order: `sort(() => -1, [1, 2, 3])` → `[3, 2, 1]` | The postconditions say nothing for inconsistent comparators; the implementation (stable insertion sort) gives `[1, 2, 3]`. | ECMAScript leaves it unspecified. |
| string functions | count UTF-16 code units: `charCodeAt(0, "😀")` → `55357`, `"😀".length` → `2` | count code points: `0x1F600`, `1` | A Dafny `string` is a sequence of Unicode scalar values. |
| `toUpper`, `toLower` (`toUpperCase`, `toLowerCase` until v0.8.0) | full Unicode case mapping: `toUpper("straße")` → `"STRASSE"`, `toUpper("ä")` → `"Ä"` | ASCII letters only: `"STRAßE"`, `"ä"` | Unicode case tables are out of scope. |

## Tests

```
tests/support.dfy   Js (a JS value type for mixed arrays/objects), NumStr, Truthy
tests/ramda/*.dfy   Ramda's test files for the release, transcribed, one Dafny
                    file per area
tests/edge/*.dfy    node-checked edge cases and Deviation* pins
```

The suite transcribes every `it` in the release's Ramda test files that the
encoding can express. Until v0.8.0 Ramda had one `test/test.<topic>.js` per
topic; from v0.9.0 it has one `test/<fn>.js` per export, and each
`tests/ramda/<area>.dfy` header lists the files it transcribes. Each header
also lists what it skips: arity checks, side-effect counting, calls with no
arguments, `null` or `undefined` in place of a list, JS coercion, reference
equality, method dispatch on non-array objects, array-like objects,
prototypes, string-keyed `sortBy`, and the unportable functions' files
(v0.11.0: `arity.js`, `binary.js`, `bind.js`, `call.js`, `construct.js`,
`constructN.js`, `curry.js`, `curryN.js`, `forEach.js`,
`forEachIndexed.js`, `functions.js`, `functionsIn.js`, `installTo.js`,
`invoker.js`, `is.js`, `isArrayLike.js`, `lift.js`, `liftN.js`,
`partial.js`, `partialRight.js`, `match.js`, `memoize.js`, `nAry.js`,
`nthArg.js`, `once.js`, `path.js`, `pathEq.js`, `dissocPath.js`,
`composeP.js`, `pipeP.js`, `tap.js`, `type.js`, `unapply.js`, `unary.js`,
`useWith.js`, `wrap.js`, `apply.js`, `assocPath.js` and `func.js`; v0.10.0
renamed `lPartial.js`, `rPartial.js`, `pCompose.js` and `pPipe.js`, and
v0.11.0 removed `op.js` and `pathOn.js` and added `invariants.js` and
`internal/_curry2.js` and `internal/_curry3.js`, on currying and arity).
`test.examplesRunner.js` (v0.5.0) runs the JSDoc examples through `dox`
and is not transcribed.

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
| v0.4.0 | 2014-08-28 | ported | — |
| v0.4.1 | 2014-08-31 | ported | — |
| v0.4.2 | 2014-09-01 | ported | — |
| v0.4.3 | 2014-09-01 | ported | — |
| v0.5.0 | 2014-09-16 | ported | — |
| v0.6.0 | 2014-10-04 | ported | — |
| v0.7.0 | 2014-10-22 | ported | — |
| v0.7.1 | 2014-10-22 | ported | — |
| v0.7.2 | 2014-10-24 | ported | — |
| v0.8.0 | 2014-11-19 | ported | — |
| v0.9.0 | 2015-01-24 | ported | — |
| v0.9.1 | 2015-01-27 | ported | — |
| v0.10.0 | 2015-02-15 | ported | — |
| v0.11.0 | 2015-03-08 | ported | — |
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

### v0.4.0 (2014-08-28)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; most of the
  diff is re-indentation, as the inner function wrapper is gone, plus JSDoc
  and quote style, and the code changes are these):
  - `reduce` becomes the primary and `foldl` its alias
    (`var foldl = R.reduce = curry3(...)`, `R.foldl = R.reduce`; commit
    "make reduce primary, foldl alias"). They are still one function, and a
    non-array argument now dispatches to its `reduce` method instead of
    `foldl`. `foldl.idx`, `foldr` and `foldr.idx` keep their primaries.
  - New: `propOrDefault(p, val, obj)` (`obj`'s own property `p`, or `val`),
    `toPairs` and `toPairsIn` (`[key, value]` pairs of the own, or all
    enumerable, properties), and the unportable `constructN`, `functions`
    and `functionsIn`.
  - `aliasFor` gives way to plain assignments; every alias group is
    unchanged.
  - `isArrayLike` no longer counts a function as array-like, so `flatten`,
    `unnest` and `chain` keep function elements whole again
    (`flatten([() => 1])` → `[fn]`, v0.3.0 gave `[]`), and it counts an
    object with `nodeType === 1` and a truthy `length` (a DOM element).
  - `concat` with a non-array second argument concatenates a String first
    argument as a string, or calls the second argument's `concat` method,
    or throws `TypeError`; on two arrays or two non-empty-first strings the
    results are unchanged, and `concat('', 'bar')` → `'bar'` (v0.2.4 to
    v0.3.0 gave the array `['b', 'a', 'r']`).
  - `pipe(f)` is `f` (was a partially applied `pipe`); `props` is
    `flip(prop)`, the same for an object argument (`props(null, 'a')` now
    throws).
  - Not visible in this encoding: `add`, `multiply`, `subtract`, `divide`,
    `modulo`, `lt`, `lte`, `gt`, `gte` (and through `flip` `subtractN`,
    `divideBy`, `moduloBy`), `prop`, `func` and `flip`'s result throw on a
    call with no arguments; `construct` uses `constructN`, so native
    constructors work; `func` passes its extra arguments; `is` stops
    treating primitives as instances of `Object`; `installTo()` needs an
    object.
- **Ramdaf:**
  - `reduce` takes `foldl`'s recursive body and an equivalent `ensures`;
    `foldl` keeps its `ensures` and becomes `reduce(fn, acc, list)`.
    `foldlIdx` (still Ramda's `foldl.idx`), `ap` and `chain` keep calling
    `foldl`; `foldr`/`reduceRight` and the `.idx` pairs are unchanged.
  - Added `propOrDefault` (`if p in obj then obj[p] else val`), `toPairs`
    and `toPairsIn` (Object; sets of pairs, as `keys` is a set).
  - "Not portable" gains `constructN` (with `construct`), `functions` and
    `functionsIn`; the `is` row shows v0.4.0's definition.
  - Deviations: `toPairs`/`toPairsIn` join the key-order row; the
    flatten-family row drops functions and gains the `nodeType` case; the
    `compose`/`pipe` row notes that node's `pipe(f)` is `f` too. `concat`'s
    empty-string case was an unrecorded difference of the v0.2.4 and v0.3.0
    ports (a character array in node, a string here), which node now
    shares; nothing changes.
  - Comments only: `concat`, `pipe`, `props`, `flatten`.
  - Tests: test.core.js's new `concat` cases ("works on strings", "is
    curried"; the method-object and throw cases are not portable),
    test.objectBasics.js's `propOrDefault` (its prototype case cannot be
    written) and test.zip.js's `toPairs`/`toPairsIn` (transcribed in
    tests/ramda/object.dfy; the prototype cases cannot be written). Not
    transcribed: the no-argument cases, `pipe(f) === f`, `clone`'s reference
    check, and the `construct`/`constructN`, `func`, `is`, `functions` and
    `functionsIn` cases. Edge cases cover `propOrDefault`, `toPairs`,
    `reduce`, `concat` of strings and function leaves; the array-like pin
    gains the `nodeType` case.
- **Expected tier: patch.** `propOrDefault`, `toPairs` and `toPairsIn` were
  added; `reduce`, `foldl` and, through them, `foldlIdx`, `reduceIdx`, `ap`,
  `chain` and `flatMap` have rewritten revealed bodies with the same results
  and contracts (compatible; nothing is made opaque)
  (`casestudy/expected/v0.4.0.json`).
- **lem:** — (not yet published from this history).

### v0.4.1 (2014-08-31)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; most of the
  diff is a jscs reformatting and new `@sig` JSDoc lines, and the code
  changes are these):
  - 16 alias names and one property are removed: `K`, `constant`
    (`always`), `all`, `any` (renamed to their aliases `every` and `some`,
    which now hold the definitions), `applyLeft`, `applyRight`, `disperseTo`,
    `distributeTo`, `drop`, `each` and `each.idx` (`forEach` and
    `forEach.idx` now hold the definitions), `first`, `flatMap`,
    `flattenDeep`, `flattenShallow`, `nth` and `sequence`. Each was `===` to
    a surviving export, so no implementation disappears.
  - `reduceRight`, `reduce.idx` and `reduceRight.idx` become the primaries,
    with `foldr`, `foldl.idx` and `foldr.idx` their aliases (`reduce` has been
    primary since v0.4.0). `foldr` now dispatches to a non-array's
    `reduceRight` method instead of `foldr`, and the `.idx` functions of
    `map`, `filter`, `foldl` and `foldr` no longer dispatch at all.
  - Not visible in this encoding: `eq` is `curry2`'d (a call with no
    arguments throws), `tail` called with four arguments returns
    `undefined`, and `curry` drops its arity type check; private `anyBlanks`
    and `partially` are deleted. Differential runs over the surviving
    exports find no other change.
- **Ramdaf:**
  - Removed `first` (Core), `sequence`, `constant`, `K` and `distributeTo`
    (Functions), and `drop`, `all`, `any`, `nth`, `flatMap`, `flattenDeep`
    and `flattenShallow` (List), with their tests and edge cases.
  - `every` and `some` take the bodies `all` and `any` had (`forall` and
    `exists` over the list).
  - `reduceRight` takes `foldr`'s recursive body and an equivalent
    `ensures`, and `foldr` becomes `reduceRight(fn, acc, list)`; likewise
    `reduceIdx` (now folding with `reduce`) and `reduceRightIdx` (with
    `reduceRight`) take the indexed bodies and `foldlIdx`/`foldrIdx` call
    them. Each keeps its contract. No other body names these functions.
  - "Not portable": `useWith`, `lPartial`, `rPartial`, `forEach` and
    `forEach.idx` lose their removed aliases; the precondition and
    deviation rows drop the removed names.
  - Tests: test.allany.js's `every`/`some` describes (renamed from
    `all`/`any`; the alias tests are gone), and the removed
    `constant`, `drop` and `nth` tests. Not transcribed: `eq`'s new "is
    curried" (it relies on `[] !== []`) and the new no-argument cases of
    `eq`, `propOrDefault` and `where`, and `nAry`'s new describe. The
    porter-added `sequence` line in the `pipe` test goes with `sequence`.
- **Expected tier: major.** `first`, `sequence`, `constant`, `K`,
  `distributeTo`, `drop`, `all`, `any`, `nth`, `flatMap`, `flattenDeep` and
  `flattenShallow` were removed; `every`, `some`, `reduceRight`, `foldr`,
  `reduceIdx`, `foldlIdx`, `reduceRightIdx` and `foldrIdx` have rewritten
  revealed bodies with the same results (`casestudy/expected/v0.4.1.json`).
- **lem:** — (not yet published from this history).

### v0.4.2 (2014-09-01)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; the rest of
  the diff is JSDoc, `ramda.` → `R.` in examples):
  - `fork` is renamed `converge`, with the same code.
  - `findLast` and `findLastIndex` loop `while (idx--)` instead of
    `while (--idx)` ("Fix two bugs"): index 0 is tested
    (`findLast(even, [2, 3, 5])` → `2`, was `undefined`;
    `findLastIndex(even, [2, 3, 5])` → `0`, was `-1`), and the empty list
    returns at once (`undefined`, `-1`) where it used to call
    `fn(undefined)` until it was truthy, possibly forever.
  - `mathMod` returns `NaN` for a modulus below 1 instead of a dividend
    below 1 ("Fix a critical bug"): `mathMod(-17, 5)` → `3` (was `NaN`) and
    `mathMod(17, -5)` → `NaN` (was `-3`); results agree where both versions
    are defined.
  - Not visible in this encoding: `_slice` dispatches on its argument count,
    which changes only non-number counts (`skip(undefined, l)` now throws);
    `func` renames a parameter; the browser global also gets `R`.
- **Ramdaf:**
  - Removed `fork` and added `converge` (Functions) with the same body and
    the same two deviations.
  - `findLast` and `findLastIndex` test index 0 and accept the empty list
    (None, -1); their `|list| > 0` precondition and its "Outside the
    modeled domain" row are gone.
  - `mathMod` requires `p >= 1` instead of `1 <= m` and `p != 0`.
  - Tests: test.compose.js's `converge` (renamed from `fork`), test.find.js's
    new first-element and empty-list cases, and test.math.js's
    `mathMod(-17, 5) == 3`. The transcribed "behaves differently than JS
    modulo" assert moves from `mathMod(17, -5)` (now `NaN`) to
    `mathMod(-17, 5)` (now defined); the `NaN` and fractional asserts are not
    transcribable. The find and `mathMod` edge cases follow the new results,
    and the negative-modulus ones are gone.
- **Expected tier: major.** `fork` was removed (`converge` added);
  `findLast`, `findLastIndex` and `mathMod` changed results, and `mathMod`'s
  precondition moved to the modulus (`casestudy/expected/v0.4.2.json`).
- **lem:** — (not yet published from this history).

### v0.4.3 (2014-09-01)

- **Ramda:** packaging only. The README's CDN links, `bower.json` and
  `package.json` move to 0.4.3; `ramda.js` (whose header still says 0.4.2)
  and `test/` are byte-identical to v0.4.2.
- **Ramdaf:** no source or test change; this entry and the manifest only.
- **Expected tier: patch.** Nothing changed (`casestudy/expected/v0.4.3.json`,
  with no changes).
- **lem:** — (not yet published from this history).

### v0.5.0 (2014-09-16)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; most of the
  diff is JSDoc and an identifier rename pass, and the code changes are
  these):
  - `skip` returns `[]` when n is at least the length ("Fix a bug in
    R.skip"): `skip(5, [1, 2])` → `[]`, where v0.2.0 to v0.4.3 threw
    `RangeError`.
  - `subtractN`, `divideBy` and `moduloBy` are removed. Their curried use
    lives on in the new `op` currying of `subtract`, `divide`, `modulo`,
    `mathMod`, `lt`, `lte`, `gt` and `gte`: one argument now fixes the second
    parameter (`subtract(5)` is `x => x - 5`, was `x => 5 - x`), and the
    placeholder `R._` fixes the first (`subtract(9, R._)`). Two-argument
    results are unchanged.
  - New: `cloneObj(obj)` (`extend({}, obj)`, a shallow copy of the own
    properties), and the unportable `curryN` (`curry`'s arity argument moves
    there), `op`, `isArrayLike` (the predicate behind `flatten`, now
    exported) and `version` (the string `'0.5.0'`). `isAtom` is removed.
  - Not visible in this encoding: `prepend`, `append` and `constructN` are
    curried; `reduce` no longer dispatches to a `reduce` method, and `ap`
    dispatches on its first argument; `slice.from` calls `xs.slice`
    directly, so a JS string now gives the same result as the port (it
    was `undefined`); `strIndexOf`/`strLastIndexOf` call the string methods
    directly; `keys` returns `[]` for a non-object; `memoize`, `nAry` and
    `arity` change for no-argument functions and arities over 10.
- **Ramdaf:**
  - Removed `subtractN`, `divideBy` and `moduloBy` (Math), with their rows.
  - `skip` drops `requires n <= |list|` and returns `[]` for n at least the
    length; no other exported body calls it.
  - Added `cloneObj` (Object; a map is a value, so the copy is the map).
  - "Not portable": `isAtom` leaves; `curryN` (with `curry`), `op`,
    `isArrayLike` and `version` (release metadata) join. The mapping row on
    currying explains the `op` sections; the `skip` precondition row now has
    only the negative n.
  - Deviations: the prototype-key row gains `cloneObj` and `mixin`, and the
    other functions that copy properties by assignment (`mapObj`,
    `mapObj.idx`, `pick`, `pickAll`, `pickWith`, `omit`, `project`), which
    drop an own `__proto__` property: an omission of the earlier ports.
  - Comments only: `ap`, `sliceFrom`, `strIndexOf`, `strLastIndexOf`.
  - Tests: test.math.js's sectioned `subtract`, `divide`, `modulo`,
    `mathMod`, `lt`, `lte`, `gt` and `gte` (transcribed by what the code
    computes; Ramda's `it` names call the placeholder form "right-curried"),
    with the removed functions' describes gone; test.filter.js's new empty
    and too-large cases and the split `skipUntil` case; test.find.js's
    `['zing']`, empty-list and curried cases; the new curried cases of
    `contains`, `uniqWith`, `or`, `and`, `prepend` and `append`; `every` on
    objects; `always()()`; `isEmpty('')`; test.fold.js's string halves and
    `foldl.idx`/`foldr.idx` bodies; the empty-array cases of `flatten`,
    `unnest`, `groupBy`, `indexOf`, `indexOf.from`, `lastIndexOf` and
    `lastIndexOf.from`; and test.clone.js's `cloneObj`. Not transcribed: the
    "throws on zero arguments" cases, method dispatch, and
    test.examplesRunner.js (JSDoc examples). Edge cases cover `skip` past the
    end and `cloneObj`, with a `__proto__` pin for `cloneObj` and `mixin`.
  - Doc fix: the README and test headers no longer list `test.maybe.js`,
    which left `test/` in v0.1.4.
- **Expected tier: major.** `subtractN`, `divideBy` and `moduloBy` were
  removed; `skip`'s precondition was dropped (compatible); `cloneObj` was
  added (`casestudy/expected/v0.5.0.json`).
- **lem:** — (not yet published from this history).

### v0.6.0 (2014-10-04)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; most of the
  diff is JSDoc, and the code changes are these):
  - `propOrDefault` is renamed `propOr`, with the same code.
  - New: `cond(condition, onTrue, onFalse)` (a function that applies one
    branch to its arguments), `trim(str)` (strips the leading and trailing
    runs of 26 whitespace characters; under node Ramda's regex fallback runs,
    as the native `trim` keeps U+180E), and the unportable `bind` and
    `invokerN`.
  - `concat` with a non-array second argument calls the first argument's
    `concat` method if it is truthy and has one, and otherwise throws, so
    `concat("", "bar")` throws `TypeError` (v0.4.0 and v0.5.0 gave `"bar"`).
    Two arrays, and two strings with a non-empty first, are unchanged.
  - `op` reverts to v0.4.3's one-argument meaning: `subtract(9)` is
    `x => 9 - x` again, and the placeholder becomes `R.__`, used as the first
    argument for the other section (`subtract(R.__, 5)` is `x => x - 5`).
    Two-argument results are unchanged.
  - Not visible in this encoding: `invoker(method)` calls the given method
    on any target (so `slice(1, 2, "abc")` is now `["b"]`, what the port
    gives); `reverse` is an explicit loop (`reverse(null)` throws); `keys`
    handles objects without a prototype again; the shared no-arguments
    exception becomes a fresh `TypeError` per throw.
- **Ramdaf:**
  - Removed `propOrDefault` and added `propOr` (Object) with the same body.
  - Added `cond` (Logic; unary, like `and`/`or`) and `trim` (String; the 26
    characters as a literal, revealed).
  - `concat`'s empty-string case is a new deviation, pinned by
    `DeviationConcatOfAnEmptyFirstString`; the Dafny body is unchanged.
  - "Not portable" gains `bind` and `invokerN`; the `op` row and the
    currying mapping follow the reverted sections.
  - Comments only: `concat`, `slice`.
  - Tests: test.math.js's sections again (one argument fixes the first
    parameter, `R.__` the second); test.objectBasics.js's `propOr`
    (renamed); test.stringBasics.js's `trim` (its shim case only exists
    without a native `trim`); and the new test.cond.js (in
    tests/ramda/logic.dfy; the forwarded arguments are a tuple).
    test.bind.js and test.invoker.js test unportable functions. Edge cases
    cover `cond`, `trim` (U+180E, U+200B, U+0085) and `propOr`.
- **Expected tier: major.** `propOrDefault` was removed (renamed `propOr`);
  `propOr`, `cond` and `trim` were added (`casestudy/expected/v0.6.0.json`).
- **lem:** — (not yet published from this history).

### v0.7.0 (2014-10-22)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; the rest is
  JSDoc and test titles losing "should"):
  - New: `scanl(fn, acc, list)` (the accumulator, then each successive
    `fn(acc, x)`), `createMapEntry(key, val)` (`{key: val}`, defined in "List
    Functions"), `has(prop, obj)` (an own property), `hasIn(prop, obj)`
    (`prop in obj`, so `Object.prototype`'s members too), `replace(pattern,
    replacement, str)` (`str.replace`), and the unportable `apply`, `lift`,
    `liftN` and `pathEq`.
  - `difference` and `differenceWith` become loops that push an element
    unless it is in the second list or already in the output; the results
    are unchanged.
  - Not visible in this encoding: `and`/`or` return the deciding operand
    instead of a boolean; `max`/`min` skip NaN and non-numbers, and
    `maxWith`/`minWith` are rewritten with the same loop; `pick`, `omit` and
    `pickWith` also take inherited enumerable properties (`keysIn`);
    `invokerN` ignores arguments past its arity; `tap` takes `(fn, x)`;
    `sortBy` caches its comparator.
- **Ramdaf:**
  - Added `scanl` and `createMapEntry` (List; the section rule), `has` and
    `hasIn` (Object; `hasIn` also answers true for the 12 names of
    `Object.prototype`, as node does for `{}`), and `replace` (String; a
    string pattern, the first occurrence, with the `$$`, `$&`, `` $` `` and
    `$'` patterns).
  - `difference` and `differenceWith` mirror the new loops (no longer
    `uniq`/`uniqWith` of a `reject`), with the same `ensures`.
  - "Not portable" gains `apply`, `lift`/`liftN` and `pathEq` (with `path`).
  - Deviations: new Typed rows for `and`/`or` and for `replace`'s RegExp
    and function forms; `createMapEntry` joins the key-to-string and
    prototype-key rows. The test-file list gains test.bind.js and
    test.invoker.js (missed in v0.6.0) and test.lift.js.
  - Comments only: `and`, `or`, `max`, `min`, `maxWith`, `pick`, `omit`,
    `pickWith`.
  - Tests: the new test.scanl.js and test.createMapEntry.js (in
    tests/ramda/list.dfy), `has`/`hasIn`, test.replace.js (its RegExp case
    is not portable), `max`/`min` in any position, the new `difference`
    cases, and the alias tests whose value halves v0.7.0 dropped (compared
    by results). Edge cases cover the new functions and `difference`, with
    `createMapEntry` added to the `__proto__` pin.
- **Expected tier: patch.** `scanl`, `createMapEntry`, `has`, `hasIn` and
  `replace` were added; `difference` and `differenceWith` have rewritten
  revealed bodies with the same results (`casestudy/expected/v0.7.0.json`).
- **lem:** — (not yet published from this history).

### v0.7.1 (2014-10-22)

- **Ramda:** version bump only. `ramda.js` changes only `R.version`
  (`'0.7.0'` → `'0.7.1'`; not ported, see "Not portable"), and `test/` is
  byte-identical to v0.7.0. The README's CDN links, `bower.json`,
  `package.json` and `ramda.min.js` follow.
- **Ramdaf:** no source or test change; this entry and the manifest only,
  as for v0.4.3 (strictly `ramda.js` is not byte-identical, but its one
  changed line is the unported `version` string).
- **Expected tier: patch.** Nothing changed (`casestudy/expected/v0.7.1.json`,
  with no changes).
- **lem:** — (not yet published from this history).

### v0.7.2 (2014-10-24)

- **Ramda** (full `ramda.js` diff, behaviour checked in node):
  - `isArrayLike` (and so `flatten`, `unnest` and `chain`) counts an object
    with a positive `length` only when it owns the indices 0 and
    `length - 1` ("fixes #482"): `flatten([{length: 2}])` → `[{length: 2}]`
    (was `[undefined, undefined]`), `flatten([{0: 'zero', length: 2}])`
    keeps the object; `{length: 0}`, full array-likes and arrays are
    unchanged.
  - Not visible in this encoding: the `op` sections ignore extra arguments
    (`subtract(R.__, 3)(10, 99)` → `7`, was `-89`; "fixes #388"), which
    needs the placeholder and more arguments than a section takes;
    `R.version` becomes `'0.7.2'`.
- **Ramdaf:** no source change beyond comments. Node moved only on
  array-like objects, which the mapping encodes as leaves, so the
  flatten-family deviation narrows: its row now gives v0.7.2's rule, and a
  new edge test shows the leaves node now keeps too. test.curry.js's new
  `op` describe and test.is.js's `isArrayLike` change test unportable
  functions.
- **Expected tier: patch.** No Dafny-visible change
  (`casestudy/expected/v0.7.2.json`, with no changes).
- **lem:** — (not yet published from this history).

### v0.8.0 (2014-11-19)

- **Ramda** (full `ramda.js` diff, behaviour checked in node; most of the
  diff is JSDoc, a `_` prefix on every private helper and local names in
  place of `R.x`, and the code changes are these):
  - Renames: `maxWith` → `maxBy` and `minWith` → `minBy` (the same code),
    and `pickWith` → `pickBy` (the same results).
  - Two renames reuse the old name. `props` (`flip(prop)`) is renamed
    `propOf`, and the new `props(ps, obj)` returns the values of a list of
    property names, in order (`props(['c', 'a', 'b'], {b: 2, a: 1})` →
    `[undefined, 1, 2]`; `props({x: 100}, 'x')` was `100` and is now
    `[undefined]`). v0.6.0's `cond(condition, onTrue, onFalse)` is renamed
    `ifElse`, with the alias `if`, and the new `cond([pred, transform], ...)`
    returns the first pair's transformer applied to the arguments whose
    predicate holds for them, or `undefined` (the old call form now throws).
  - `_slice` allocates `Math.max(0, to - from)` elements, so a negative
    length copies nothing instead of throwing `RangeError`:
    `take(-1, [1, 2, 3])` → `[]`, and `remove` cuts a negative start at 0
    (`remove(-1, 2, [1, 2, 3, 4, 5])` → `[2, 3, 4, 5]`) unless
    `start + count < 0`, which still reads undefined holes.
  - `_hasMethod` tests `obj != null` instead of truthiness ("fix
    R.concat('')"): `concat("", "bar")` → `"bar"` and `concat("", "")` →
    `""`, which threw since v0.6.0. `union`, now `compose(uniq, _concat)`,
    gives `union("", "b")` → `["b"]`, which threw through `R.concat`.
  - `xprodWith` is removed; `xprod` keeps its own loops.
  - New: `nth(n, list)` in "Core Functions" (a negative n counts from the
    end; out of range `undefined`), `prependTo` and `appendTo`
    (`flip(_prepend)`, `flip(_append)`), `cloneDeep` (a deep copy that keeps
    functions by reference), `commuteMap(fn, of, list)` and
    `commute(of, list)` (a list of functors to a functor of lists),
    `lens(get, set)` (a getter function with `set` and `map` properties,
    defined in "List Functions"), `assoc(prop, val, obj)` (a shallow copy
    with one property set), and the unportable `argN`, `unapply`,
    `pCompose`, `pPipe`, `type` and `assocPath`. `invoker` is removed, and
    `invokerN(n, 'name')` looks the method up on the target.
  - Not visible in this encoding: `isEmpty` is `val == null || val.length
    === 0` (`isEmpty(0)` and `isEmpty({})` are now `false`); `head` and
    `last` are `nth(0)` and `nth(-1)` and `tail` is `_slice(list, 1)`, so
    all three throw on `null` or no argument; `join`, `slice`, `substring`,
    `charAt`, `charCodeAt`, `toUpperCase`, `toLowerCase` and `split` call
    the target's own method, with the same results on strings and arrays
    (`slice(1, 2, "abc")` is the string `"b"`, was `["b"]`: the same Dafny
    string); `wrap` keeps the wrapped function's arity; `liftN` no longer
    dispatches to a non-array functor; `flip` moves among the internal
    functions with the same body; `R.version` becomes `'0.8.0'`.
- **Ramdaf:**
  - Removed `maxWith`, `minWith` (Math), `pickWith` (Object) and
    `xprodWith` (List); added `maxBy`, `minBy` and `pickBy` with the same
    bodies and contracts.
  - `Object.props` is now `props(ps: seq<string>, obj): seq<Option<V>>`,
    and its old body moves to the new `propOf`. `Logic.cond` is now
    `cond(pairs: seq<(A -> bool, A -> B)>): A -> Option<B>`, and its old
    body moves to the new `ifElse`, with the alias `if_` (`if` is a Dafny
    keyword).
  - `take` takes `n: int` and gives `[]` for a negative n; `remove` drops
    `requires 0 <= start` and cuts a negative start at 0. `take`'s row in
    "Outside the modeled domain" goes, and `remove`'s narrows.
  - `xprod` is its own recursion instead of a call of `xprodWith`, with the
    same results.
  - Added `nth`, `prependTo`, `appendTo` and `cloneDeep` (Core, by the
    section rule; `nth`'s pre-v0.4.1 namesake was in List, and `cloneDeep`
    is the value itself and, unlike v0.1.1's, takes any `T`), `commuteMap`,
    `commute` and `lens` (List; arrays only), and `assoc` (Object, a map
    update). `lens` returns the new `Prelude.Lens` record (`get`, `set_`,
    `map_`), whose fields are partial arrows (`-->`), so a getter or setter
    may carry a precondition and `map_` requires both. Core and Logic now
    import Prelude.
  - `concat`'s empty-string deviation is gone: node now agrees with the
    port, and its pin becomes an agreement edge. `union` threw on an empty
    first string from v0.6.0 to v0.7.2, a deviation the earlier ports never
    recorded; node now agrees with it too.
  - "Not portable": `invoker` leaves; `argN` and `unapply` join `apply`,
    `type` joins `isArrayLike`, `assocPath` joins the path row, and
    `pCompose` and `pPipe` get a row (promises).
  - Deviations: `cond`'s pairs are one `seq` (Fixed arity), `ifElse` and
    `if_` join the unary row, `commute` and `commuteMap` cover arrays only,
    a lens is a record, `assoc` joins the key-to-string row, and `assoc` and
    `cloneDeep` join the `__proto__` row; `maxBy`, `minBy` and `pickBy`
    replace the old names. The mapping gains a lens row, and `cond`'s
    arguments join the pair row.
  - Comments only: `isEmpty`, `head`, `last`, `tail`, `concat`, `join`,
    `slice`, `union`.
  - Tests: test.core.js's new `isEmpty` cases on lists, `prependTo`,
    `appendTo`, `nth` and the empty-string `concat` cases; test.cond.js's
    `ifElse` (renamed, with "is aliased by `if`") and the new `cond`
    describe; test.objectBasics.js's `propOf` (renamed, with a missing
    property), the new `props`, `pickBy` (renamed) and `assoc`;
    test.math.js's `maxBy` and `minBy` (renamed); and the new
    test.cloneDeep.js (its value cases), test.commute.js, test.identity.js
    (`identity`) and test.lens.js. test.product.js's `xprodWith` describe is
    gone. Not transcribed: the `null`/`undefined` throws, the non-list
    `isEmpty` cases, test.cloneDeep.js's cycles, Dates, instances and
    reference checks, and the cases of the unportable `argN`, `unapply`,
    `pCompose`, `pPipe`, `type`, `assocPath`, `invokerN` and `wrap`. Edge
    cases cover the new functions, negative `take` and `remove` arguments,
    and the empty-string `concat` and `union`; the `__proto__` pin gains
    `cloneDeep` and `assoc`.
- **Expected tier: major.** `maxWith`, `minWith`, `pickWith` and
  `xprodWith` were removed; `props` and `cond` changed signature and
  meaning; `take` and `remove` accept more input with every previous result
  unchanged, and `xprod`'s revealed body was rewritten (compatible); 15
  symbols were added (`casestudy/expected/v0.8.0.json`).
- **lem:** — (not yet published from this history).

### v0.9.0 (2015-01-24)

- **Ramda** (every export compared with its v0.9.0 `src/<fn>.js` and the
  internal helpers it requires, behaviour checked in node; `ramda.js` is
  split into one CommonJS module per export plus `src/internal/_*.js`, and
  `dist/ramda.js` is built from them; `test/` is split into one file per
  export):
  - Renames with the same code: `filter.idx`, `reject.idx`, `map.idx`,
    `mapObj.idx`, `foldl.idx` (= `reduce.idx`), `foldr.idx` (=
    `reduceRight.idx`), `forEach.idx` and `insert.all` become
    `filterIndexed`, `rejectIndexed`, `mapIndexed`, `mapObjIndexed`,
    `foldlIndexed`, `foldrIndexed`, `forEachIndexed` and `insertAll` (no
    function properties remain); `skip` → `drop`, `every` → `all`, `some`
    → `any`, `repeatN` → `repeat`, `toUpperCase` → `toUpper`,
    `toLowerCase` → `toLower`, `alwaysTrue` → `T`, `alwaysFalse` → `F`,
    `allPredicates` → `allPass`, `anyPredicates` → `anyPass`, `invokerN` →
    `invoker`, and `argN` → `nthArg` (which also counts a negative n from
    the end).
  - `skipUntil` is replaced by `dropWhile`, which drops the leading
    elements that satisfy the predicate: `dropWhile(p, l)` is v0.8.0's
    `skipUntil(x => !p(x), l)`.
  - Removed: the aliases `car`, `cdr`, `cons`, `push` and `if`; `reduce` and
    `reduceRight`, whose aliases `foldl` and `foldr` keep the code (`foldr`
    no longer dispatches to a `reduceRight` method); `size`, whose alias
    `length` becomes `list != null && is(Number, list.length) ?
    list.length : NaN`; `alwaysZero`; `indexOf.from`, `lastIndexOf.from`
    and `slice.from`; and `version`.
  - "unify R.clone, R.cloneObj, and R.cloneDeep": `clone` takes v0.8.0's
    `cloneDeep` code, a deep copy of any value, and `cloneDeep` and
    `cloneObj` are removed. `clone({a: 1})` and `clone(5)` were
    `RangeError` and are now copies; `clone('abc')` was `['a', 'b', 'c']`
    and is now `'abc'`; on lists the values are unchanged.
  - `propOr(val, p, obj)` takes the default first ("take default value as
    first argument to R.propOr"): `propOr(7, 'a', {a: 1})` → `1` (was
    `'a'`).
  - `eq` is `Object.is` ("made R.eq behave as Object.is from ES6"):
    `eq(0, -0)` → `false`, `eq(NaN, NaN)` → `true`, so
    `eq(negate(0), 0)` → `false`.
  - `arity` and `nAry` throw for an arity above 10, and `allPass`/`anyPass`
    compute their arity as the longest predicate's, so `allPass([])` and
    `anyPass([])` throw (the two-argument forms are unchanged).
  - `sort` is still `clone(list).sort(cmp)`, so it now deep-copies the list
    and throws on a string (`sort(cmp, 'cab')`, was `['a', 'b', 'c']`).
  - New: `init` (`slice(0, -1)`), `mapAccumL` and `mapAccumR`, `evolve`,
    `invert`, `invertObj`, `inc`, `dec`, `negate`, `eqDeep` (deep equality,
    `@category Relation`), `isNil` (`x == null`, `@category Type`), and the
    unportable `call` and `__` (the placeholder, now the exported object
    `{ramda: 'placeholder'}`).
  - Not visible in this encoding: `concat` and `contains` are `op`-curried
    and `union` is curried; `isEmpty(null)` → `false` (`Object(list).length
    === 0`); `times` allocates `new Array(Number(n))`; `reverse`, `xprod`,
    `commuteMap` (which stops calling a functor's `map`), `wrap`, `curryN`,
    `memoize`, `liftN` and the `lens` setters (curried) are rewritten;
    private helpers are renamed and split out, with the same results.
- **Ramdaf:**
  - Removed `car`, `cdr`, `cons`, `push`, `size`, `repeatN` and `cloneDeep`
    (Core), `alwaysZero`, `alwaysTrue` and `alwaysFalse` (Functions),
    `reduce`, `reduceRight`, `reduceIdx`, `foldlIdx`, `reduceRightIdx`,
    `foldrIdx`, `mapIdx`, `mapObjIdx`, `filterIdx`, `rejectIdx`, `skip`,
    `skipUntil`, `every`, `some`, `indexOfFrom`, `lastIndexOfFrom` and
    `sliceFrom` (List), `cloneObj` (Object), `allPredicates`,
    `anyPredicates` and `if_` (Logic), and `toUpperCase` and `toLowerCase`
    (String).
  - Added under the new names, with the old bodies and contracts: `T` and
    `F` (Functions); `all`, `any`, `drop`, `filterIndexed`,
    `rejectIndexed`, `mapIndexed`, `mapObjIndexed`, `foldlIndexed` and
    `foldrIndexed` (List); `allPass` and `anyPass` (Logic); `toUpper` and
    `toLower` (String); and `repeat`, which `@category List` puts in List.
    `dropWhile` (List) negates `skipUntil`'s test. `insertAll` keeps its
    name, so it has no entry.
  - `clone` becomes `clone<T>(value: T): T`, `cloneDeep`'s signature and
    body, and `propOr` takes `(val, p, obj)` and tests `has(p, obj)`, as
    Ramda's `propOr` calls `has` (both breaking).
  - `foldl` and `foldr` take the recursions of `reduce` and `reduceRight`,
    `length` is `|list|` instead of `size(list)`, and `commuteMap` folds
    with `foldl` instead of `reduce` (compatible, same results); `ap`,
    `chain` and `commute` follow as knock-ons.
  - Added `isNil(x: Option<T>)` (Core: `@category Type`), `init`,
    `mapAccumL` and `mapAccumR` (List), `evolve` (transformations of type
    `Option<V> -> V`, called with `None` for a missing key), `invert` (the
    keys holding each value, as a set) and `invertObj` (Object), `inc`,
    `dec` and `negate` (Math, calling `add` and `multiply`), and `eqDeep`
    (Data: structural `==`).
  - "Outside the modeled domain": `head`/`last` lose `car`, `skip` becomes
    `drop` and `repeatN` `repeat`; `invertObj` requires distinct values (the
    last key in property order wins in node).
  - "Not portable": `version` leaves (D4); `invokerN` → `invoker`,
    `forEach.idx` → `forEachIndexed`, `argN` → `nthArg`; `call` joins the
    variadic row and `__` the `op` row. `isNil` is ported.
  - Deviations: new rows for `eq`/`eqDeep` and signed zero, `allPass([])`
    and `anyPass([])`, `isNil`'s `Option`, `evolve`'s typed
    transformations and `sort` on a string, each pinned where behavioural;
    `invert` joins the key-order row and, with `invertObj`, the
    key-to-string row; `clone`, `evolve`, `invert` and `invertObj` join the
    `__proto__` row (with a pin for `invert`'s throw on prototype-named
    values); `inc`, `dec` and `negate` join the int row; the renamed
    functions replace their old names. The mapping cites the `*Indexed`
    functions, `mapAccumL`/`mapAccumR`'s pairs and the `R.__` object.
  - The module rule for new functions is now the `@category` table, and
    the src headers cite `src/<fn>.js` instead of `ramda.js` line ranges.
  - Comments only: `isEmpty`, `times`, `concat`, `contains`, `reverse`,
    `xprod`, `mapObj`, `ap`, `join`, `slice`, `insertAll`, `eq`, `sum`,
    `sort`.
  - Tests: the per-area files now cite v0.9.0's per-function test files.
    Retargeted to the new names: `T`/`F`, `all`/`any`, `allPass`/`anyPass`,
    `drop`, `filterIndexed`, `rejectIndexed`, `mapIndexed`,
    `mapObjIndexed`, `foldlIndexed`, `foldrIndexed`, `insertAll`, `repeat`
    (with its new curried case), `toUpper`/`toLower`, and `clone` (the old
    `cloneDeep` cases); `propOr`'s arguments are swapped. New: `dropWhile`,
    `length`, `init`, `inc`, `dec`, `negate`, `mapAccumL`, `mapAccumR`,
    `evolve`, `invert`, `invertObj`, `eqDeep`, `isNil`, `containsWith`,
    `union`'s and the placeholder cases of `concat` and `contains` (as
    lambdas), `eq`'s new values, and `lens`'s curried setters and composed
    lens. Gone with their functions: `size`, `skipUntil`, `alwaysZero`,
    `cloneObj`, the shallow `clone` cases, the `reduce` alias cases, the
    `.from` describes and `ifElse`'s alias case. Edge cases cover the new
    functions and move to the new names, with pins
    `DeviationEqSignedZero`, `DeviationEqDeepSignedZero`,
    `DeviationAllPassOfTheEmptyList`, `DeviationSortOfAString` and
    `DeviationInvertOfPrototypeNamedValues`.
- **Expected tier: major.** 33 symbols were removed (mostly renames); `clone`
  and `propOr` changed signature; `foldl`, `foldr`, `length` and
  `commuteMap` have rewritten revealed bodies, and `ap`, `chain` and
  `commute` follow (compatible); 28 symbols were added
  (`casestudy/expected/v0.9.0.json`).
- **lem:** — (not yet published from this history).

### v0.9.1 (2015-01-27)

- **Ramda** (the `src/` and `test/` diff, behaviour checked in node; the rest
  of the release is build tooling, docs and the regenerated `dist/`):
  - `countBy` ignores inherited properties of its result ("ignore inherited
    properties in R.countBy"): `counts[key] = (has(key, counts) ?
    counts[key] : 0) + 1`, so `countBy(R.identity, ['abc', 'toString'])` →
    `{abc: 1, toString: 1}`, where v0.9.0 appended the 1s to the inherited
    `toString`'s source; `__proto__` is still dropped.
  - `sortBy` sorts a deep copy of the list itself, `clone(list).sort(…)`
    with the keys computed on the fly ("simplify implementation of
    R.sortBy"), instead of `{key, val}` pairs. Ordinary lists sort as
    before; a JS string now throws, `undefined` elements go last, and the
    elements are copies (an own `__proto__` key is lost, and identity).
  - `_keyValue` and `_compareKeys` are deleted; a `prop` example leaves the
    JSDoc.
- **Ramdaf:** no signature, contract or revealed body changes.
  - Comments only: `countBy`, `sortBy` and `sort`; the headers cite v0.9.1.
  - Deviations: the `__proto__` row's `countBy` part narrows to `__proto__`,
    and the row gains `sortBy` and `sort` (whose deep copies since v0.9.0
    were an omission of that port); the string row covers `sortBy` too; a
    new row records that `sort` and `sortBy` put `undefined` elements last
    (for `sort` an omission of the earlier ports).
  - Tests: countBy.js's new "ignores inherited properties". The
    `hasOwnProperty` line of the `groupBy`/`countBy` pin becomes an
    agreement edge (`CountByOfPrototypeNamedKeys`), with `sortBy` edges and
    the pins `DeviationSortByOfAString`, `DeviationSortAndSortByUndefinedLast`
    and `DeviationPrototypeKeysAreOrdinaryInSortedCopies`.
- **Expected tier: patch.** Node moved to the port's results for `countBy`,
  and `sortBy` changed only on input the port cannot single out
  (`casestudy/expected/v0.9.1.json`, with no changes).
- **lem:** — (not yet published from this history).

### v0.10.0 (2015-02-15)

- **Ramda** (the `src/` and `test/` diff, behaviour checked in node, with a
  differential run of every renamed export against its old name):
  - Renames with the same code ("use consistent names"): `foldl` →
    `reduce`, `foldr` → `reduceRight`, `foldlIndexed` → `reduceIndexed`,
    `foldrIndexed` → `reduceRightIndexed`, `mapAccumL` → `mapAccum`,
    `mapAccumR` → `mapAccumRight`, `scanl` → `scan`, `unfoldr` → `unfold`,
    and the unportable `lPartial` → `partial`, `rPartial` → `partialRight`,
    `pCompose` → `composeP` and `pPipe` → `pipeP`; the private `_foldl`
    becomes `_reduce`. `mixin` is renamed `merge` ("rename R.mixin"), with
    the same body, now `op`-curried (`merge(R.__, b)`).
  - New: `mergeAll(list)` (`reduce(merge, {})`, `@category List`),
    `dissoc(prop, obj)` (a copy without the property, `@category Object`)
    and `defaultTo(d, v)` (`v == null ? d : v`, `@category Logic`).
  - `sortBy` sorts `_slice(list)` instead of a deep `clone(list)` ("preserve
    object identity in R.sortBy"): a JS string sorts again
    (`sortBy(c => c.charCodeAt(0), 'cba')` → `['a', 'b', 'c']`, v0.9.1
    threw), and element objects keep their identity and an own `__proto__`
    key; `undefined` elements still go last.
  - `invert` tests `has(val, out)` ("ignore inherited properties in
    R.invert"): a value naming an `Object.prototype` member is an ordinary
    key (`invert({a: 'toString', b: 'x'})` → `{toString: ['a'], x: ['b']}`,
    v0.9.1 threw), except `__proto__`, whose array becomes the result's
    prototype.
  - `of(x)` drops its Fantasy-land `container` parameter ("remove dispatch
    from R.of").
  - Not visible in this encoding: `reject` calls the exported, dispatching
    `filter`; `memoize` keys its cache by each argument's string and type
    tag and caches nullary calls; `constructN` takes at most 10 arguments;
    `liftN` maps with the dispatching `map`; `mergeAll`'s `{}` accumulator
    is shared across calls (`mergeAll([]) === mergeAll([])`).
- **Ramdaf:**
  - Removed `foldl`, `foldr`, `foldlIndexed`, `foldrIndexed`, `mapAccumL`,
    `mapAccumR`, `scanl` and `unfoldr` (List) and `mixin` (Object); added
    `reduce`, `reduceRight`, `reduceIndexed`, `reduceRightIndexed`,
    `mapAccum`, `mapAccumRight`, `scan` and `unfold` (List) and `merge`
    (Object) with the same bodies and contracts. `reduce` and `reduceRight`
    return to List, where v0.9.0 removed them; `merge` goes in Object, by its
    `@category` and `mixin`'s module (the list `merge` that v0.2.4 removed
    was in Core).
  - `ap`, `chain` and `commuteMap` fold with `reduce` instead of the removed
    `foldl` (Ramda's `_ap` and `commuteMap` use `_reduce`), with the same
    results; `commute` follows (compatible).
  - Added `mergeAll` (List; `merge(acc, obj)` written out as `acc + obj`,
    as List does not import Object), `dissoc` (Object; `pickBy` of the other
    keys, as Ramda's `_pickBy`, with `ensures dissoc(p, obj) == obj - {p}`)
    and `defaultTo<T>(d: T, v: Option<T>): T` (Logic, a total `match`; D9).
  - Comments only: `of`, `reject`, `invert`, `sortBy`, `mapObj`,
    `partition`, `groupBy`, `sum`, `product`; the headers cite v0.10.0.
  - "Not portable": `partial`/`partialRight` and `composeP`/`pipeP` take the
    renamed rows; the `memoize` and `constructN` rows note their changes.
  - Deviations: the `of` row retires (node has the port's one-parameter
    `of`); `sortBy` leaves the string row and the `__proto__` copies (node
    now agrees with the port), and `invert`'s prototype-name case narrows to
    `__proto__`; `isNil`'s Typed row covers `defaultTo` too, and the mapping's
    `undefined` row says so; the `__proto__` row gains `merge`, `mergeAll` and
    `dissoc`; the renamed functions replace the old names in the rows and
    the mapping, which lists `merge` among the placeholder-curried functions.
  - Tests: retargeted to the renamed files (reduce.js, reduceRight.js,
    reduceIndexed.js, reduceRightIndexed.js, mapAccum.js, mapAccumRight.js,
    scan.js, unfold.js, merge.js) with their methods renamed; new: merge's
    placeholder "is curried" (as a lambda), mergeAll.js, dissoc.js,
    defaultTo.js (with `Js` values; null and undefined are both `None`) and
    invert's "ignores inherited properties". Not transcribed: reject's and
    sortBy's new dispatch, identity and `arguments` cases, mergeAll's and
    dissoc's prototype cases, and invert's and invertObj's primitive and
    null cases. The pin `DeviationSortByOfAString` and the `sortBy` line of
    `DeviationPrototypeKeysAreOrdinaryInSortedCopies` become the agreement
    edge `SortByOfAStringAndPrototypeKeys`, and the `toString` line of
    `DeviationInvertOfPrototypeNamedValues` the edge
    `InvertOfPrototypeNamedValues`; new edges cover `mapAccum`, `mergeAll`,
    `dissoc` and `defaultTo`, and the `__proto__` pins gain `merge`,
    `mergeAll` and `dissoc`.
- **Expected tier: major.** Nine symbols were removed (renames); `ap`,
  `chain`, `commuteMap` and `commute` have rewritten revealed bodies with the
  same results (compatible); 12 symbols were added
  (`casestudy/expected/v0.10.0.json`).
- **lem:** — (not yet published from this history).

### v0.11.0 (2015-03-08)

- **Ramda** (the `src/` and `test/` diff, every changed module compared in
  normalised form, behaviour checked in node with a differential run of the
  ported exports; most of the diff is a currying overhaul):
  - `differenceWith` writes each kept element at its own index,
    `out[idx] = first[idx]` (commit b7a8f67b, a mechanical
    `push` → `xs[xs.length] = x` pass that got this file wrong): every
    dropped element before the last kept one leaves a hole
    (`differenceWith(eq, [1, 2, 3, 4], [2])` → `[1, <hole>, 3, 4]`, was
    `[1, 3, 4]`). Results that keep a prefix of the first list are
    unchanged, and Ramda's own tests keep one. (v0.14.0 restores the push.)
  - `negate` is `-n` (was `multiply(-1)`), and `dissoc` is its own `for…in`
    copy loop (was `_pickBy`, now deleted); both give the same results.
  - New: `lensOn(get, set, obj)` (`@category Object`), a function
    `lns() = get(obj)` with the properties `lns.set = set` and
    `lns.map(fn) = set(fn(get(obj)))` (its JSDoc example passes the object
    first and throws; the code and the tests take it last), and the
    unportable `dissocPath`. `op` and `pathOn` are removed, and the path
    functions take a list of property names instead of a dotted string.
  - `@deprecated since v0.11.0` (documentation only): `I`, `get`,
    `appendTo`, `prependTo`, `propOf` and `installTo`.
  - Not visible in this encoding: `_curry1`/`_curry2`/`_curry3` take the
    placeholder `R.__` in any position and return the function itself when
    called with no arguments; `op` is gone, so `subtract`, `divide`,
    `modulo`, `mathMod`, `lt`, `lte`, `gt`, `gte`, `concat`, `contains` and
    `merge` are plain `_curry2` (`subtract(R.__)(5)(17)` → `-12`, was `12`);
    `compose(f)` and `pipe(f)` are wrappers with `f`'s arity instead of `f`;
    `converge(after, f)` waits for another function; `slice` and `init`
    take `arguments`; `assoc`'s `for…in` copy makes an object value under
    `__proto__` the prototype; `mergeAll` no longer shares its `{}`
    accumulator; `new Array(n)` → `[]` lets fractional lengths through;
    `pick`, `omit` and `pickBy` are inline loops, `has` is `_curry2(_has)`,
    and `isNil` and the other one-argument functions are `_curry1`.
- **Ramdaf:**
  - `differenceWith` gains the exact precondition that its kept elements
    are a prefix of `first` (once an element is dropped, every later one is
    dropped against `second` or that prefix); its body and contract are
    otherwise unchanged (breaking, a strengthened precondition), with a row
    in "Outside the modeled domain".
  - `negate` is `-n` and `dissoc` is `obj - {p}`, mirroring Ramda's new
    bodies (compatible: rewritten revealed bodies, same results).
  - Added `lensOn<A, V, B>(get: A --> V, set_: V --> B, obj: A):
    LensOn<V, B>` (Object, by `@category`) and the record
    `Prelude.LensOn<!V, B>(get: () --> V, set_: V --> B, map_: (V -> V)
    --> B)`, as `lens` has `Prelude.Lens`, with partial arrows likewise.
  - "Not portable": `op` leaves (the `__` row keeps its history),
    `pathOn` leaves the path row and `dissocPath` joins it; `installTo`
    is deprecated and `bind` keeps its arity.
  - Comments only: `I`, `get`, `appendTo`, `prependTo` and `propOf`
    (deprecated), `concat`, `contains`, `merge`, `has`, `isNil`, `assoc`,
    `pick`, `slice`, `mergeAll`, `compose`, `pipe`, `converge`; the headers
    cite v0.11.0.
  - Deviations: a `lensOn` row next to `lens`'s; the `compose`/`pipe` and
    `converge` rows note the new one-function forms, and the `__proto__` row
    `assoc`'s and `dissoc`'s loops. The mapping gains a bound-lens row, and
    its currying and no-argument rows describe the placeholder in any
    position and `f()` returning `f`.
  - Tests: lensOn.js (new; its `typeof` checks hold by construction),
    has.js's split two-argument `it` and "is curried, op-style" (as lambdas),
    concat.js's and contains.js's rewritten placeholder `it`s (the
    `concat(R.__)('bar')('foo')` line, now `'barfoo'` in node, goes),
    `always(undefined)()` and `identity(undefined)` in comments, and
    witness asserts that put differenceWith.js's two `it`s and the edge
    cases inside the new domain. The 62 removed "throws on zero arguments"
    `it`s were never transcribed; the headers say so. Not transcribed:
    `compose`'s and `pipe`'s "can be applied to one argument" (no unary
    form), the `arguments` and dispatch cases of `slice` and `init`, and the
    unportable dissocPath.js, invariants.js and `internal/` files. The edge
    case `differenceWith((a, b) => a < b, [3, 1, 2, 5, 4], [2])` leaves the
    domain and goes; new edges cover `lensOn` and `differenceWith` inside
    its domain.
- **Expected tier: major.** `differenceWith` gained a precondition;
  `negate` and `dissoc` have rewritten revealed bodies with the same results
  (compatible); `lensOn` and `Prelude.LensOn` were added
  (`casestudy/expected/v0.11.0.json`).
- **lem:** — (not yet published from this history).

## Toolchain

- Dafny 4.10 (lem-pinned) and the Lemmata package manager `lem`.
- `lem test` verifies `src/**/*.dfy`, then builds and runs `tests/**/*.dfy`
  together with it. The equivalent Dafny commands are:

  ```
  dafny verify src/*.dfy
  dafny test src/*.dfy tests/support.dfy tests/ramda/*.dfy tests/edge/*.dfy
  ```
