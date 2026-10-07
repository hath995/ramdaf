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
| a documented "no value" result (`find` miss → `undefined`, `maxBy([])` → `undefined` (until v0.16.0 made `maxBy` binary), `nth` out of range → `undefined` (until v0.4.1 removed `nth`, and again since v0.8.0; on a string `''` since v0.16.0, `nth(3, 'abc')`), `cond` when no predicate matches → `undefined` (v0.8.0)) | `Option<T>` |
| `where`'s spec object, whose properties are predicates on the test object's property (since v0.14.0; until v0.13.0 functions or values) | `map<string, Option<V> -> bool>`: each predicate gets the property, `None` when it is absent (until v0.13.0 `map<string, Ramdaf.Prelude.SpecVal<V>>`, `Pred(fn)` for a function and `Val(v)` for a value; v0.14.0 moved the values to `whereEq` and removed `SpecVal`) |
| nested arrays (the input of `flatten` and `unnest`) | `Ramdaf.Prelude.Tree<T>`: `Node(children)` for an array, `Leaf(v)` for any other element (an array-like element is not flattened; see "Deviations") |
| a two-element array used as a pair (`zip`'s and `xprod`'s elements, `partition`'s result, `fromPairs`' elements, `cond`'s `[predicate, transformer]` pairs, the `[accumulator, element]` arrays of `mapAccum` and `mapAccumRight` (`mapAccumL` and `mapAccumR` in v0.9.x) and their results, `pair`'s result (v0.18.0), `converge`'s list of two branching functions (v0.18.0; see "Deviations"), and the results of `splitAt` and `splitWhen` (v0.19.0)) | `(A, B)` |
| a lens (v0.16.0, "composable lenses": `lens`'s, `lensIndex`'s and `lensProp`'s result), a van Laarhoven lens `Functor f => (a -> f a) -> s -> f s`: a function that takes a function from the focus to a functor and returns one from the whole to the functor, run by `view` (with a `Const` functor), `over` (with an `Identity` functor) and `set`, and composed with `compose` | `Ramdaf.Prelude.Lens<S, V, X>`, the type `(V --> Functor<X, V>) -> (S --> Functor<X, S>)`, with the datatype `Prelude.Functor<X, T> = Const(c: X) \| Identity(v: T)` for the two functors and `Prelude.map_` for their `map`; X is the type a `Const` carries (`view` takes a lens with X the focus type). The arrows from values are partial: a getter or setter that throws or is `undefined` on part of its domain gives the lens a precondition there (see "Outside the modeled domain"). From v0.8.0 to v0.15.1 a lens was a function `l` with the properties `l.set` and `l.map` (`lensOn`'s bound lens, v0.11.0, one of no arguments), the records `Prelude.Lens<A, V>(get, set_, map_)` and `Prelude.LensOn<V, B>(get, set_, map_)` |
| number | `int`, or `real` for `divide` and for the results of `mean` and `median` (v0.14.0) |
| string | `string` (a sequence of Unicode code points) |
| predicate, "truthy" result | `T -> bool` |
| an index callback, called `fn(x, idx, list)` (`mapIndexed` and the other `*Indexed` functions from v0.9.0 to v0.15.1, the `.idx` properties until v0.8.0) | `(T, nat, seq<T>) -> R` (folds: `(A, T, nat, seq<T>) -> A`) |
| comparator `(a, b) -> negative/0/positive` | `(T, T) -> int` |
| `===` | `==` (structural; see "Deviations") |
| multi-argument function, auto-curried | an **uncurried** Dafny function with the same parameter order. Dafny cannot partially apply a function, so `f(a)` becomes `x => f(a, x)`. For the `op` functions (`subtract`, `divide`, `modulo`, `mathMod`, `lt`, `lte`, `gt`, `gte`), `f(a)` is `x => f(a, x)` too, and `f(R.__, b)` (the placeholder, since v0.6.0; a non-enumerable `undefined` until v0.8.0, the exported object `{ramda: 'placeholder'}` since v0.9.0 and `{'@@functional/placeholder': true}` since v0.15.0, which also curries `concat` and `contains` this way, and since v0.10.0 `merge`) is `x => f(x, b)`. (In v0.5.0 alone, `f(a)` was `x => f(x, a)` and `f(a, R._)` was `x => f(a, x)`.) Since v0.11.0 `op` is gone and every curried function takes the placeholder in any position: `f(R.__, b)` is still `x => f(x, b)`, while `f(R.__)` is `f` itself, so `subtract(R.__)(5)` is `x => 5 - x` (from v0.6.0 to v0.10.0 `op` made it `x => x - 5`). |
| a call with no arguments, `f()` | `f(())` when the function takes one argument of any type. (Since v0.11.0 a curried Ramda function called with no arguments returns itself, `identity()` is `identity`; the functions Ramda returns, such as `always(7)`, `T` and `cond(…)`'s result, are not curried, and they are the ones called this way.) |

## Modules and exports (v0.19.1)

| Module | Exports |
|---|---|
| `Ramdaf.Core` | clone, isEmpty, prepend, nth, head, last, tail, append, concat, identity, times, length, isNil |
| `Ramdaf.Functions` | compose, pipe, flip, converge, always, T, F, composeK, pipeK, juxt |
| `Ramdaf.List` | reduce, reduceRight, unfold, mapSeq (`map`), mapObjIndexed, filter, reject, takeWhile, take, dropWhile, drop, find, findIndex, findLast, findLastIndex, all, any, contains, uniq, uniqWith, pluck, flatten, zipWith, zip, lens, xprod, reverse, range, indexOf, lastIndexOf, join, slice, remove, insert, insertAll, partition, ap, of, empty, chain, commuteMap, commute, unnest, zipObj, fromPairs, scan, repeat, init, mapAccum, mapAccumRight, mergeAll, aperture, none, adjust, update, intersperse, dropRepeats, dropRepeatsWith, lensIndex, dropLast, dropLastWhile, takeLast, takeLastWhile, splitEvery, uniqBy, allUniq, pair, indexBy, sequence, traverse, splitAt, splitWhen, transpose, without |
| `Ramdaf.Sort` | comparator; sort and sortBy by contract (`provides`) |
| `Ramdaf.Object` | prop, props, propOr, has, hasIn, keys, keysIn, toPairs, toPairsIn, values, valuesIn, pick, pickAll, omit, pickBy, merge, eqProps, where, assoc, propEq, evolve, invert, invertObj, dissoc, lensProp, whereEq, view, over, set_ (`set`), objOf, mergeWith, mergeWithKey |
| `Ramdaf.Logic` | and, or, not, both, either, complement, allPass, anyPass, ifElse, cond, defaultTo, propSatisfies, when, unless |
| `Ramdaf.Math` | add, multiply, subtract, divide, modulo, mathMod, sum, product, lt, lte, gt, gte, max, maxBy, minBy, min, inc, dec, negate, mean, median |
| `Ramdaf.String` | toUpper, toLower, trim, replace, split |
| `Ramdaf.Data` | union, unionWith, difference, differenceWith, intersection, intersectionWith, countBy, groupBy, project, equals, identical, eqBy, symmetricDifference, symmetricDifferenceWith |

That is 186 of Ramda v0.19.1's 231 export names (since v0.9.0 Ramda has no
functions stored as properties of exports). The other 45 names are listed
under "Not portable".

### Support declarations

These are exported but are not Ramda functions:

- `Ramdaf.Prelude` reveals the datatypes `Option`, `Tree` and `Functor`
  (v0.16.0), the functor's map `map_` (v0.16.0) and the type `Lens`
  (v0.16.0) from the mapping. (`SpecVal`, `where`'s spec values from
  v0.1.1, was removed in v0.14.0; the record datatypes `Lens` (v0.8.0) and
  `LensOn` (v0.11.0) gave way in v0.16.0 to the van Laarhoven type `Lens`,
  which reuses the name.)
- Some modules `provides` an import alias, because an exported signature,
  postcondition or revealed body names that module:
  - `Prelude` in Core, List, Object, Logic and Data (Core for `nth` and,
    since v0.9.0, `isNil`, Logic for `cond`, since v0.8.0, `defaultTo`,
    since v0.10.0, and `propSatisfies`, since v0.16.0); Math provided it
    for `maxBy` and `minBy` and Functions for `composeL` and `pipeL` until
    v0.15.1;
  - `List` in Sort, Data and, since v0.16.0, Functions (`composeK`);
  - `Object` in Data;
  - `Sort` in Math (`median`, since v0.14.0).

### Internal Ramda functions

Ramda v0.19.1 does not export the helpers `_makeFlat`, `_checkForMethod` and
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
`_assocPath` and `_dissocPath`; v0.12.0 deletes `_ap`, `_pairWith` and
`_pickAll` and adds the transducer machinery: `_dispatchable`,
`_isTransformer`, `_reduced`, `_stepCat`, `_xwrap` and one `_x<name>`
transformer per dispatching function; v0.14.0 deletes `_satisfiesSpec` and
adds `_eq` (`Object.is`, behind `eq`, `_indexOf` and `_lastIndexOf`),
`_composeL`, `_toString`, `_toISOString`, `_quote`, `_xfBase` and
`_xdropRepeatsWith`; v0.15.0 deletes `_eq`, renames `_eqDeep` to `_equals`
(behind `equals`) and adds `_curryN`, `_chain`, `_xchain`, `_flatCat` and
`_forceReduced`; v0.15.1 restores `_eq`, behind the deprecated `eq`;
v0.16.0, "reduce the number of internal functions", deletes `_add`,
`_all`, `_any`, `_append`, `_assoc`, `_chain`, `_compose`, `_composeL`,
`_createComposer`, `_createMapEntry`, `_createMaxMin`, `_createMaxMinBy`,
`_dissoc`, `_eq`, `_extend`, `_filterIndexed`, `_forEach`, `_gt`,
`_lastIndexOf`, `_lt`, `_multiply`, `_nth`, `_pluck` and `_prepend`, whose
exported functions inline them, renames `_baseCopy` to `_clone` and adds
`_isNumber`, `_isString` and `_pipe`; v0.18.0 deletes `_hasMethod` and
`_predicateWrap` and adds `_aperture`, `_arrayFromIterator`,
`_isArguments`, `_isObject`, `_isRegExp`, `_of` and `_xaperture`; v0.19.0
adds `_dropLast`, `_dropLastWhile`, `_isPlaceholder`, `_xdropLast` and
`_xdropLastWhile`, and its `uniqWith`, `differenceWith` and
`intersectionWith` use `_containsWith` alone, as `containsWith` is gone).
Since v0.9.0 they are the modules `src/internal/_*.js` (until v0.8.0 local
to `ramda.js`), and Ramdaf does not export them either. (`isArrayLike`, private since v0.3.0, is exported in v0.5.0 and is
not portable.) (`containsWith` was
internal until v0.1.5 exported it, and `uniqWith` until v0.2.0; both are in
List, and v0.19.0 removed `containsWith` again. Until v0.2.3 the `*With` functions in Data carried `uniqWith`'s
recursion themselves; since v0.2.4 they call `List.uniqWith`, as Ramda
does.)

## Not portable

These Ramda v0.19.1 exports are not ported, rather than faked:

| Export | Why |
|---|---|
| `curry`, `curryN`, `uncurryN` | Ramdaf functions are uncurried, and Dafny has no partial application to curry into. (v0.5.0 moved `curry`'s arity argument to the new `curryN(n, fn)`.) `uncurryN(n, fn)` (v0.14.0) goes the other way, a function of n arguments that applies the curried `fn` to them a few at a time, by each intermediate function's `length` (`uncurryN(2, a => b => a + b)(1, 2)` → `3`): n fixes the result's arity at run time. |
| `__` | The currying placeholder, the object `{'@@functional/placeholder': true}` (v0.15.0, which recognises any object with that property; `{ramda: 'placeholder'}` from v0.9.0 to v0.14.0; until v0.8.0 a non-enumerable `undefined`). Since v0.11.0 every curried function accepts it in any argument position (`subtract(R.__, 5)`, `has(R.__, obj)`). Until v0.10.0 it served `op` (v0.5.0), which v0.11.0 removed: `op(fn)` made a binary function from one with exactly two parameters (v0.6.0; before, at least two); in v0.5.0 its one-argument call fixed the second parameter, with the placeholder `R._` for the first, and from v0.6.0 one argument fixed the first parameter and the placeholder as the first argument the second (v0.9.0 curried `concat` and `contains`, and v0.10.0 `merge`, the same way). The uncurried port has no partial application (see the mapping). (`version`, the release string from v0.5.0 to v0.8.0, was listed here as release metadata until v0.9.0 removed it.) |
| `nAry`, `unary`, `binary` | Change a function's reported arity (`fn.length`), which Dafny functions do not have (`unary(fn)` is `nAry(1, fn)`, `binary(fn)` is `nAry(2, fn)`; v0.2.0; `arity`, deprecated in v0.15.0, was here until v0.16.0 removed it). |
| `invoker` | Calls a JS method on an object at run time: `func` (deprecated in v0.12.0, removed in v0.14.0) looked it up by name, `invoke(methodName, args, obj)` (v0.12.0 to v0.15.1; v0.13.0 moved `obj` last; deprecated in v0.15.0, removed in v0.16.0) was `obj[methodName].apply(obj, args)`, and so, since v0.8.0, does `invokerN(n, 'name', ...args)` (since v0.15.0 `invoker(arity, method)` takes no initial arguments), which calls the last argument's own method `name` and which v0.9.0 renames `invoker` (from v0.6.0 to v0.7.2 `invoker(method)` and `invokerN(n, method)` took the method itself; until v0.5.0 `invoker` took a name and a prototype; v0.8.0 removed that `invoker`). |
| `bind` | Fixes the `this` of a JS function (v0.6.0; since v0.11.0 the result keeps `fn`'s arity); Dafny functions have no `this`. |
| `useWith` | Argument transformers of a run-time number: `useWith(fn, [t1, …, tn])` (since v0.18.0 a list, and the transformers get the result's `this`; until v0.17.1 separate arguments, `useWith(fn, t1, …, tn)`) is a function of n arguments, each passed through its transformer, the rest passed on, curried to n. (v0.3.0 removed `use(fn).over(...)` and added the alias `disperseTo`, which v0.4.1 removed.) |
| `partial`, `partialRight` | Partial application of a run-time number of arguments: since v0.18.0 `partial(fn, [a, b])` takes them as a list (until v0.17.1 `partial(fn, a, b)`), and the result takes the rest, any number. (v0.4.1 removed their aliases `applyLeft` and `applyRight`; v0.10.0 renamed `lPartial` and `rPartial` to `partial` and `partialRight`.) |
| `memoize`, `once`, `addIndex` | Rely on hidden mutable state: `addIndex(fn)` (v0.15.0) makes an indexed version of a list function such as `map` (`addIndex(map)((x, i) => x + i, [10, 20])` → `[10, 21]`) by counting the calls of the callback it passes in, so it needs `fn` to call it once per element in order, and the callback's type changes with `fn`'s; and `memoize`'s cache is keyed by `R.toString` of the arguments (v0.14.0; from v0.10.0 to v0.13.0 by each argument's string and type tag, `42::[object Number]`, and `String(arg)` before), which no generic Dafny function can compute. |
| `wrap` | Variadic wrapper (`wrapper(fn, ...arguments)`). |
| `apply`, `unapply`, `nthArg`, `call` | Variadic. `apply` spreads a list of run-time length into a function's positional arguments, `fn.apply(this, args)` (v0.7.0), and passes `this`; `unapply(fn)` (v0.8.0), its inverse, collects any number of arguments into one list for `fn` (`unapply(JSON.stringify)(1, 2, 3)` → `'[1,2,3]'`; a Dafny `unapply(fn: seq<A> -> B)` would be `fn` itself); `nthArg(n)` (`argN` in v0.8.0) returns a function of any number of arguments that returns the nth (`nthArg(1)('a', 'b')` → `'b'`; since v0.9.0 a negative n counts from the end); `call(fn, ...args)` (v0.9.0) is `fn.apply(this, args)`. |
| `composeP`, `pipeP` | Promise-aware composition (v0.8.0; `pCompose` and `pPipe` until v0.9.1): each intermediate result is tested at run time for a `then` method, and a promise's value is passed on inside `then`, asynchronously. Dafny has no promises or run-time type tests, and without them `pCompose` would be `compose`. |
| `lift`, `liftN` | Lift a function of a run-time arity over lists (v0.7.0): `liftN(n, fn)` takes n lists, and `lift(fn)` reads `fn.length`. Dafny functions have no run-time arity. |
| `construct`, `constructN` | Call JS constructors with `new` (`constructN(n, Fn)`, v0.4.0, also fixes the result's reported arity at n, and since v0.10.0 takes at most 10 arguments; `construct(Fn)` is `constructN(Fn.length, Fn)`). |
| `tap` | Its purpose is a side effect (`fn(x)`), which a pure function cannot have. (Until v0.2.4 `K` was an alias of `tap`; v0.3.0 made it an alias of `always`. v0.7.0 reversed the arguments to `tap(fn, x)`.) |
| `forEach` | Calls `fn` on each element for its side effect and returns the list itself. (Until v0.4.0 the definitions were `each` and `each.idx`, with `forEach` as the alias; v0.4.1 removed `each`; v0.9.0 renamed `forEach.idx` to `forEachIndexed`, which v0.15.0 deprecated and v0.16.0 removed.) |
| `isArrayLike`, `type`, `toString` | Test the run-time type of an arbitrary value (`isNaN(x)`, from v0.13.0 until v0.15.0 removed it for `identical(NaN, x)`, was `typeof x === 'number' && x !== x`, and a NaN is not an `int`, so on every representable value it would have been the constant `false`; `toString(val)`, v0.14.0, writes any value as JavaScript source, choosing the form by its run-time type: `toString([1, 'a', {b: null}])` → `'[1, "a", {"b": null}]'`, with Dates, `arguments` objects and boxed primitives each in their own syntax): v0.5.0 exports `isArrayLike`, the predicate behind `flatten`, whose rule v0.7.2 narrows to objects owning their extreme indices (v0.5.0 also removed `isAtom`, which was here for the same reason; `functions` and `functionsIn`, v0.4.0, deprecated in v0.18.0 and removed in v0.19.0, had their own row: they listed the property names whose values are functions, `typeof obj[key] === 'function'`, inherited ones too for `functionsIn`, a run-time type test on each value, which a `map<string, V>` of one value type cannot make); `type(val)` (v0.8.0) names the type (`'Null'`, `'Undefined'`, or `Object.prototype.toString`'s tag such as `'Object'`, `'Number'` or `'Array'`), which a generic Dafny function cannot inspect. |
| `is`, `propIs` | Test a value's constructor and prototype chain at run time: `is(ctor, val)` is `val != null && val.constructor === ctor \|\| val instanceof ctor` (v0.4.0; v0.3.0 had `val != null && Object(val) instanceof ctor`), and `propIs(type, name, obj)` (v0.16.0) is `propSatisfies(is(type), name, obj)`. (`is` is also a Dafny keyword.) |
| `match`, `test` | Regular expressions (`test(pattern, str)`, v0.12.0, runs a copy of the RegExp's `test`, and since v0.18.0 throws `TypeError` for a pattern that is not a RegExp). |
| `into`, `transduce`, `reduced` | Transducers (v0.12.0; `reduced(x)`, v0.15.0, wraps x in the "reduced" marker object `{'@@transducer/value': x, '@@transducer/reduced': true}`, with which a `reduce` callback stops the fold: `reduce((a, x) => x > 2 ? reduced(a) : a + x, 0, [1, 2, 3, 4])` → `3`; the port's folds run to the end, README "Deviations"): `transduce(xf, fn, acc, list)` folds `list` with `xf(fn)`, and `into(acc, xf, list)` with `xf` applied to a step function chosen by the run-time type of `acc` (an array, a string, an object, or a transformer). A transducer `xf` is built by calling `map`, `filter`, `take` and the other dispatching functions with a transformer object (one with `@@transducer/step` and `@@transducer/result` methods; `step` and `result` until v0.13.0) in list position, a run-time test of the argument; ends early through the `@@transducer/reduced` marker (`__transducers_reduced__` until v0.13.0). The port's functions take lists, and a Dafny function cannot be both a list function and a transducer, nor test its argument's shape. |
| `path`, `pathEq`, `pathOr`, `pathSatisfies`, `lensPath`, `assocPath`, `dissocPath` | Walk an arbitrary JS value along a list of property names (v0.2.0; v0.3.0 removed `pathWith`; `pathEq(path, val, obj)`, v0.7.0, compares what `path` finds, since v0.14.0 with `Object.is`; `pathOr(d, path, obj)`, v0.18.0, is `defaultTo(d, path(path, obj))`, the default where `path` finds `null`, `undefined` or NaN; `pathSatisfies(pred, path, obj)`, v0.19.0, is `path.length > 0 && pred(path(path, obj))`, and `lensPath(path)`, v0.19.0, is `lens(path(path), assocPath(path))`; `assocPath(path, val, obj)`, v0.8.0, copies every object on the way and sets the last property, replacing a value that is not an object with `{}`; `dissocPath(path, obj)`, v0.11.0, copies every object on the way and deletes the last property, turning arrays, strings and other primitives on the way into objects: `dissocPath(['a', 'b'], {a: 'str'})` → `{a: {0: 's', 1: 't', 2: 'r'}}`. Until v0.10.0 the path was a dot-separated string, and `pathOn(sep, str, obj)`, removed in v0.11.0, split it on any separator; since v0.14.0 an empty path gives the object itself): object properties, array indices (`path(['a', 'e', 'f', '1'], obj)` → `101`, Ramda's own test) and string characters, returning whatever value is there (an object, an array or a primitive). The mapping has no type for such a heterogeneous nested value: a `map<string, V>` is homogeneous, and `Tree<T>` has no keys. A nested-object datatype would cover only the object case and leave most of Ramda's `path` tests untranscribable. |

## Outside the modeled domain (preconditions)

| Function | Ramda v0.19.1 (node) | Ramdaf |
|---|---|---|
| `head`, `last` | `head([])` → `undefined` (`[]`, the empty list itself, in v0.1.0); `last([])` → `undefined` (since v0.8.0 they are `nth(0)` and `nth(-1)`, and since v0.16.0 `head('')` and `last('')` → `''`, not a character; `car`, an alias of `head` until v0.8.0, shared the row) | `requires \|list\| > 0` |
| `repeat` (`repeatN` until v0.8.0), `times` | `new Array(n)` throws `RangeError` for a negative n: `repeat(7, -2)` (since v0.2.0; it was `[]`), `times(f, -1)` (v0.2.3; since v0.19.1 `times` throws its own `RangeError: n must be a non-negative number`, for NaN too) | `n: nat` |
| `remove` | (v0.2.2) `_slice(list, start + count)` reads before the start for `start + count < 0` (`remove(2, -5, [1, 2, 3, 4, 5])` → `[1, 2, undefined, undefined, undefined, 1, 2, 3, 4, 5]`, `remove(-2, 1, [1, 2, 3, 4, 5])` → `[undefined, 1, 2, 3, 4, 5]`). (Until v0.7.2 `_slice(list, 0, Math.min(start, length))` also threw `RangeError` for a negative start, as in `remove(-1, 1, [1, 2, 3, 4, 5])`, and Ramdaf required `0 <= start`; since v0.8.0 that cut is empty.) | `requires 0 <= start + count` |
| `mean`, `median` | (v0.14.0) `mean([])` and `median([])` → `NaN` | `requires \|list\| > 0` |
| `divide` | `divide(1, 0)` → `Infinity` | `requires` a nonzero divisor |
| `modulo` | `modulo(1, 0)` → `NaN` | `requires` a nonzero divisor |
| `mathMod` | (v0.4.2) `NaN` unless m and p are integers and p is at least 1: `mathMod(17, -5)` and `mathMod(17, 0)` → `NaN`. (v0.3.0 to v0.4.1 tested the dividend instead, against the documentation: `mathMod(-17, 5)` and `mathMod(0, 5)` were `NaN` and `mathMod(17, -5)` was `-3`, and Ramdaf required `1 <= m` and `p != 0`.) | `requires p >= 1` |
| `zipObj` | (v0.3.0) a key without a value gets `undefined` and is still an own property: `zipObj(['a', 'b'], [1])` → `{a: 1, b: undefined}`, whose `Object.keys` are `['a', 'b']` (Ramda's test "extra keys are undefined") | `requires \|keys\| <= \|values\|` |
| `fromPairs` | (v0.3.0) an element that is not an array, or is empty, is skipped (`fromPairs([['a', 1], 'x', [], {}])` → `{a: 1}`); a one-element array gives an `undefined` value (`fromPairs([['a']])` → `{a: undefined}`), and elements past the second are ignored | not expressible: the elements are typed pairs `(string, V)` |
| `invertObj` | (v0.9.0) for a repeated value the key last in property order wins: `invertObj({b: 'v', a: 'v'})` → `{v: 'a'}`, `invertObj({a: 'v', b: 'v'})` → `{v: 'b'}` (Ramda's test "prefers the last key found…"), and a map has no property order | `requires` distinct values |
| `evolve` | (v0.15.0) a transformation that is an object is applied recursively to the object's value (`evolve({nested: {second: add(-1)}}, {first: 1, nested: {second: 2, third: 3}})` → `{first: 1, nested: {second: 1, third: 3}}`, Ramda's test "is recursive"), and one that is neither a function nor an object leaves the value (`evolve({a: 5}, {a: 1})` → `{a: 1}`; until v0.14.0 both threw `TypeError: fn is not a function`) | not expressible: the transformations are `Option<V> -> V` functions |
| `whereEq` | (v0.14.0) a spec property whose value is `undefined`: `whereEq({x: undefined}, {})` and `whereEq({x: undefined}, {x: undefined})` → `true`, `whereEq({x: undefined}, {x: 1})` → `false` (Ramda's test "matches specs that have undefined properties"), as `eq(undefined)` holds for an absent or undefined test property. (`where` had this row until v0.13.0, when its spec values could be values: since v0.2.3 `where({x: undefined}, {})` was `true`, and `where(spec, null)` was `false`; since v0.14.0 its spec values are predicates, which get an absent and an undefined property alike, as `None` here, and `where(spec, null)` throws `TypeError` for a non-empty spec.) | not expressible: an undefined property is an absent one |
| `lensIndex` | (v0.14.0) the getter `nth(n)` is `undefined` out of range: `view(lensIndex(5), [1, 2])` and `view(lensIndex(-3), [1, 2])` → `undefined` (v0.16.0; `lensIndex(5)([1, 2])` until v0.15.1), and `over` calls its function on that (`over(lensIndex(5), x => x.a, [1, 2])` throws `TypeError`; `over(lensIndex(0), x => x + 1, [])` → `[]`, as the setter then leaves the list, `[NaN]` until v0.15.0). Since v0.16.0 `set` runs the getter too, before ignoring its result: `set(lensIndex(5), 9, [1, 2])` → `[1, 2]`. (In v0.14.0 and v0.15.0 the setter's `_slice(xs, n + 1)` read before the start for n ≤ −2, `lensIndex(-2).set(9, [1, 2])` → `[9, undefined, 1, 2]`, and the port required `n >= -1`; since v0.15.1 the setter is `update(n)`, defined for every n: `[9, 2]`; in v0.15.1 the setter alone was total here.) | the lens requires the index (a negative n counted from the end) in the list, so `view`, `over` and `set_` do |
| `lensProp` | (v0.14.0) the getter `prop(k)` is `undefined` when the object lacks k (`view(lensProp('x'), {})`, and `over(lensProp('x'), x => x + 1, {})` → `{x: NaN}`; `lensProp('x')({})` and `.map` until v0.15.1), and the inherited member for a name of `Object.prototype` (`view(lensProp('toString'), {})` is a function); since v0.16.0 `set` runs the getter too (`set(lensProp('x'), 9, {})` → `{x: 9}`) | the lens requires `k in obj`, so `view`, `over` and `set_` do (until v0.15.1 the setter, `assoc`, was total here) |
| `compose`, `pipe` of lenses | (v0.16.0; `composeL` and `pipeL` from v0.14.0 to v0.15.1) the inner lens runs on the outer getter's result: where the outer getter is `undefined`, the inner one gets `undefined`, so `set(compose(lensProp('a'), lensProp('x')), 1, {})` and `view` of it throw `TypeError` (until v0.15.1 `composeL(lensProp('x'), lensProp('a')).set(1, {})` → `{a: {x: 1}}`), while an inner getter that is `undefined` is outside the inner lens's domain (`set(…, 1, {a: {}})` → `{a: {x: 1}}`) | composed preconditions: the composed lens requires the outer lens's and then the inner lens's on the outer focus |
| `splitEvery` | (v0.16.0) a length n ≤ 0 throws `Error: First argument to splitEvery must be a positive integer` | `requires n > 0` |
| `uniqBy` | (v0.19.0) a key `fn` gives as `null` puts `null` in the result in place of the element: `uniqBy(x => null, [1, 2])` → `[null]` (`uniq`, `uniqBy(identity)`, puts the element, which is the `null` itself) | not expressible: fn's keys are values of a generic type, and a Dafny value is never `null` |

## Deviations

These are differences on input the encoding can represent. A behavioural
difference is pinned by a `Deviation*` test in `tests/edge/`; a difference in
a signature (an arity or an operand type) is enforced by the types.

| Function(s) | Ramda v0.19.1 (node) | Ramdaf | Why |
|---|---|---|---|
| `identical` (`eq` until v0.14.0 and in v0.15.1) | `identical` (`Object.is`) compares arrays and objects by reference: `identical([], [])` → `false`. (Until v0.14.0 `===` or `Object.is` also made `contains`, `indexOf`, `lastIndexOf`, `isSet`, `uniq`, `union`, `intersection`, `difference`, `propEq`, `eqProps`, `whereEq` (v0.14.0; `where`'s value entries before) and `dropRepeats` (v0.14.0) compare by reference: for `Ro = [{a:1},…,{a:4}]` and `So = [{a:3},…,{a:6}]`, `union(Ro, So).length` → `8`, `intersection(Ro, So).length` → `0` and `difference(…)` → `4`. Since v0.15.0 they compare with `R.equals`, deep equality, as here, except that in v0.15.0 alone `uniq` kept a JS `Set`, which compares by reference (unless an object has an `equals` method), so `uniq([{a: 1}, {a: 1}])` kept both and `union(Ro, So).length` was still `8`; v0.15.1 makes `uniq` `uniqWith(equals)` again.) | Structural `==`: `true` | Dafny values have no identity. |
| `keys`, `keysIn`, `toPairs`, `toPairsIn`, `invert` | `keys({b: 1, a: 2})` → `['b', 'a']` and `toPairs({b: 1, a: 2})` → `[['b', 1], ['a', 2]]`, in insertion order, and `invert({b: 'v', a: 'v'})` (v0.9.0) → `{v: ['b', 'a']}` | `{"a", "b"}`, `{("a", 2), ("b", 1)}` and `map["v" := {"a", "b"}]`, sets | A `map` has no key order. |
| `values`, `valuesIn` | `values({a: 1, b: 1})` → `[1, 1]`, in key order | `multiset{1, 1}` | A `map` has no key order. |
| `unfold` (`unfoldr` until v0.9.1) | loops until `fn` returns a falsy value, possibly forever | extra `fuel: nat` parameter; stops after `fuel` elements | Dafny functions must terminate. |
| `compose`, `pipe`, `composeK`, `pipeK` | variadic: `compose(a, b, c, d)`, and so `composeK(h, g, f)` (v0.16.0; since v0.16.0 lenses compose with `compose` too, and from v0.14.0 to v0.15.1 `composeL(l1, l2, l3)` and `pipeL` composed them) | binary: `compose(a, compose(b, compose(c, d)))`, `composeK(h, composeK(g, f))`. There is no unary or nullary form; `compose(f)` and `pipe(f)` give `f`'s results in node too (since v0.11.0 through a wrapper with `f`'s arity; `f` itself from v0.3.0 and v0.4.0 to v0.10.0), and `composeK()` is `identity`. | Dafny functions have fixed arity. |
| `always`, `T`, `F` (`alwaysTrue`, `alwaysFalse` and `alwaysZero` until v0.8.0) | ignore however many arguments they get | take exactly one argument of any type (`always(7)(())`) | Fixed arity. |
| `both`, `either`, `complement` (`and`, `or`, `not` until v0.11.0), `converge`, `ifElse` (and its alias `if_` in v0.8.0), `cond`, `juxt` (v0.19.0) | forward any number of arguments (`juxt([add, multiply])(2, 3)` → `[5, 6]`) | unary functions (pass a tuple, or `()` for none) | Fixed arity. |
| `converge` (`fork` until v0.4.1) | since v0.18.0 takes a list of any number of branching functions, `converge(after, [f1, f2, f3])` (`converge(a => [a], [x => x + 1])(5)` → `[6]`; `converge(after, [])` throws, as the result's arity is `-Infinity`), and its result is curried to the longest function's arity (since v0.14.0). Until v0.17.1 the functions were separate arguments, `converge(after, f1, f2, f3)` (its v0.4.2 documentation names three), and from v0.11.0 it was `curryN(3, …)`, so `converge(after, f)` waited for another function | exactly two, as a pair: `converge(after, (f1, f2))` (until v0.17.1 `converge(after, f1, f2)`) | Fixed arity. |
| `allPass`, `anyPass` (`allPredicates`, `anyPredicates` until v0.8.0) | since v0.18.0 the result is curried to the longest predicate's arity (`allPass([odd, gt5, plusEq])(9)(9)(9)(9)` → `true`), and a second argument is ignored (`allPass(preds, v)` is the predicate); until v0.17.1 `allPass(preds, v)` applied at once, and the result reported the longest predicate's arity | `allPass(preds)(v)`; unary (tuple the arguments for more); no arity | Fixed arity. |
| `add`, `subtract`, `multiply`, `sum`, `product`, `lt`, `lte`, `gt`, `gte`, `max`, `min`, `modulo`, `mathMod`, `inc`, `dec`, `negate` | JS numbers (doubles) and coercion: `lt("abc", "xyz")` → `true`, `max(-4.3, -1.1)` → `-1.1` (`max([-4.3, -1.1])` until v0.15.1), `max('a', 'b')` (v0.16.0) → `'b'`, `inc('1')` (v0.9.0) → `'11'` | `int` (`divide`: `real`) | Typed. |
| `identical`, `equals`, `contains`, `indexOf`, `lastIndexOf`, `isSet` (until v0.18.0), `allUniq`, `uniq`, `uniqBy`, `union`, `intersection`, `difference`, `propEq`, `eqProps`, `whereEq`, `dropRepeats`, `eqBy`, `without`, `symmetricDifference` | `identical` (v0.15.0; `eq` from v0.9.0 to v0.14.0 and in v0.15.1) is `Object.is`, and `equals` (v0.15.0; `eqDeep` from v0.9.0 to v0.14.0 and in v0.15.1) compares numbers with it: `-0` differs from `0` and `NaN` equals itself, and JS arithmetic on representable input makes `-0`: `identical(negate(0), 0)`, `identical(multiply(-1, 0), 0)`, `identical(modulo(-4, 2), 0)` and `equals([negate(0)], [0])` → `false` (all `true` in v0.8.0). Since v0.14.0 the others compare with `Object.is` too (since v0.15.0 through `R.equals`: `uniq` looked `0` and `-0` up with it in v0.15.0 and is `uniqWith(equals)` since v0.15.1; `===` until v0.13.0): `contains(negate(0), [0])` and `propEq('a', negate(0), {a: 0})` (`propEq(negate(0), 'a', {a: 0})` in v0.16.0) → `false`, `indexOf(negate(0), [0])` → `-1`, `isSet([0, negate(0)])` → `true`, `uniq([0, negate(0)])` and `dropRepeats` of it → `[0, -0]`, `uniqBy(identity, [negate(0), 0])` (v0.16.0) → `[-0, 0]`, `intersection([0], [negate(0)])` → `[]`; since v0.18.0 `allUniq([0, negate(0)])` (isSet's code) → `true`, and `eqBy(identity, 0, negate(0))` and `eqBy(x => x * 0, -1, 1)` → `false`; since v0.19.0 `uniq` is `uniqBy(identity)`, whose JS `Set` keeps a repeated `-0`: `uniq([negate(0), negate(0)])` and `union([negate(0)], [negate(0)])` → `[-0, -0]`, `uniqBy(x => x * 0, [-1, -2])` → `[-1, -2]`, and `without([0], [negate(0)])` → `[-0]` and `symmetricDifference([0], [negate(0)])` → `[0, -0]` | `true` (`allUniq`, `isSet`: `false`): an `int` has no `-0` | Typed: doubles are `int` here. |
| `isNil`, `defaultTo` | test any value for `null` or `undefined`: `isNil(null)` and `isNil(undefined)` → `true`, `isNil(0)`, `isNil('')`, `isNil([])` → `false` (v0.9.0); `defaultTo(d, v)` (v0.10.0) is `v == null ? d : v`, and the default and the value may differ in type: `defaultTo(42, null)` → `42`, `defaultTo(42, 'a real value')` → `'a real value'`; since v0.18.0 a NaN value gives the default too (`defaultTo(42, NaN)` → `42`) | take an `Option<T>`: `isNil(None) == true`, `isNil(Some(v)) == false`, `defaultTo<T>(d: T, v: Option<T>): T` (`defaultTo(d, None) == d`, `defaultTo(d, Some(v)) == v`); `None`, the port's `undefined`, stands for `null` too | Typed: a Dafny value is never `null`, and one `T` cannot hold both a value and `null` (nor a default of another type). |
| `groupBy`, `indexBy` | use whatever `fn` returns as a key, converted to a string (`indexBy(x => x > 2, [1, 3])` (v0.19.0) → `{false: 1, true: 3}`): `groupBy(x => x > 2, [1, 3])` → `{false: [1], true: [3]}` (`partition` did so from v0.1.4 to v0.2.4) | `fn: T -> string` | Typed. |
| `both`, `either` (`and`, `or` until v0.11.0) | since v0.7.0 return the deciding operand, `f(x) && g(x)` (`\|\|`), not a boolean: `either(x => 0, x => 'b')(1)` → `'b'` (was `true`), so `either(prop('a'), always('d'))` is a default-value combinator | `T -> bool` predicates and a `bool` result | Typed. |
| `and`, `or`, `not` | (v0.12.0) `a && b`, `a \|\| b` and `!a` on any values, returning the deciding operand: `and(1, 0)` → `0`, `or('', 0)` → `0`, `and(true, [])` → `[]`, `not('')` → `true` | `bool` operands and result | Typed (as for v0.1.0 to v0.1.3's boolean operators). |
| `replace` | the pattern may be a RegExp (`replace(/\d+/g, 'num', '1 2 three')` → `'num num three'`, every match with the `g` flag) and the replacement a function (`replace('a', x => x.toUpperCase(), 'banana')` → `'bAnana'`); other values are converted to strings (`replace(1, 'x', 'a1b')` → `'axb'`) | string pattern and replacement only | Typed; regular expressions are not portable (as for `match`). |
| `join` | converts elements to strings: `join("~", [1, 2, 3, 4])` → `"1~2~3~4"` | `seq<string>` elements | Typed. |
| `zipObj`, `fromPairs`, `createMapEntry` (until v0.18.0), `objOf`, `assoc`, `invert`, `invertObj` | convert keys to strings: `zipObj([1, 2], ['x', 'y'])` → `{"1": 'x', "2": 'y'}`, `createMapEntry(1, 'x')`, `objOf(1, 'x')` (v0.18.0) and `assoc(1, 'x', {})` (v0.8.0) → `{"1": 'x'}`, and `invert({a: 1, b: 1})` (v0.9.0) → `{"1": ['a', 'b']}` (the values become keys) | `string` keys (and `string` values for `invert` and `invertObj`) | Typed. |
| `empty` | takes any argument: since v0.16.0 `empty({a: 1})` → `{}`, `empty('abc')` → `''` and `empty(5)` → `undefined` (and since v0.18.0 an `arguments` object gives an empty one), and `x.constructor.empty()` is called when there is one (until v0.15.1 `empty(5)`, `empty({})` and `empty()` → `[]`) | `empty(x: seq<T>): seq<T>` (a Dafny string's empty value is `""`) | Typed: the result's element type comes from the argument. |
| `chain` | keeps a result of `f` that is not array-like as one element: `chain(x => x * 2, [1, 2])` → `[2, 4]`, `chain(x => 'ab', [1, 2])` → `['ab', 'ab']` | `f: A -> seq<B>`; a string result is a sequence of characters and is concatenated: `chain(x => "ab", [1, 2]) == "abab"` | Typed; a Dafny `string` is a `seq<char>`. |
| `commute`, `commuteMap`, `sequence`, `traverse`, `composeK`, `pipeK` | work on a Fantasy-land functor, with `of` building the result's functor (v0.8.0; `sequence(of, t)` and `traverse(of, f, t)`, v0.19.0, also dispatch to a traversable's `sequence` method; the documentation points at `Maybe` and `Either`); since v0.9.0 the private `_map` and `_ap` call only the `ap` method of `of`'s result, so a functor's `map` is no longer used; `composeK` and `pipeK` (v0.16.0) chain any monad through its `chain` method (Ramda's tests use an `Identity` object: `composeK(h, g, f)(new Identity(8)).value` → `50`) | arrays only: `fn: seq<A> -> seq<B>`, `of: seq<B> -> seq<seq<B>>`, and `composeK` chains lists with `List.chain` | Typed; no Dafny value has methods. |
| `lens`, `lensIndex`, `lensProp` | since v0.16.0 return a van Laarhoven lens, a function of a functor-valued function, which `view`, `over` and `set` run with their own `Const` and `Identity` objects and whose `R.map` dispatches to any functor's `map` method; `over`'s function may return a value of another type (`over(lensProp('x'), String, {x: 1})` → `{x: '1'}`). (From v0.8.0 to v0.15.1 a lens was a function `l` with the properties `l.set` and `l.map`, `l(a)` being `get(a)`, and `composeL`, `pipeL` and `lensOn` built such lenses.) | `Prelude.Lens<S, V, X>`, the same function over the one datatype `Prelude.Functor<X, T>` (`Const(c)`, `Identity(v)`), with `over`'s `f: V -> V` (until v0.15.1 the records `Prelude.Lens` and `Prelude.LensOn`, `l.get(a)`, `l.set_(v, a)`, `l.map_(fn, a)`) | Dafny has no type quantified over functors, and no value has methods; typed. |
| `flatten`, `unnest` | since v0.3.0 flatten every array-like element. Since v0.7.2 that is an array, an `arguments` object, or another object (not a `String`) whose `length` is 0, or is positive with own properties `0` and `length - 1`, or (with `nodeType === 1`) is truthy: `flatten([{length: 0}])` → `[]`, `flatten([{length: 2, 0: 'a', 1: 'b'}])` → `['a', 'b']`, `flatten([{nodeType: 1, length: -1}])` → `[]`. (v0.3.0 also counted a function, whose `length` is its arity, until v0.4.0; and v0.3.0 to v0.7.1 counted any object with a numeric `length` of at least 0, so `flatten([{length: 2}])` was `[undefined, undefined]`, where node and the port now agree on `[{length: 2}]`.) | only a `Node` is flattened: `flatten([Leaf(map["length" := 0])])` is `[map["length" := 0]]` | `Tree<T>` marks nesting by constructor. |
| `groupBy`, `countBy`, `zipObj`, `fromPairs`, `createMapEntry` (until v0.18.0), `objOf`, `indexBy`, `mergeWith`, `mergeWithKey`, `clone`, `merge`, `mergeAll`, `assoc`, `evolve`, `invert`, `invertObj`, `dissoc`, `lensProp`, `whereEq`, `pick`, `prop`, `props`, `pickAll`, `pluck`, `project`, `where`, `propSatisfies` | a key that names an `Object.prototype` member is not an ordinary property: `groupBy(x => 'hasOwnProperty', [1])` → `{hasOwnProperty: [undefined, 1]}`, `countBy(x => '__proto__', [1, 2])` → `{}` (since v0.9.1 `countBy` counts every other member name as an ordinary key; until v0.9.0 `countBy(x => 'hasOwnProperty', [1, 2])` → `'function hasOwnProperty() { [native code] }11'`), `zipObj(['__proto__', 'a'], [1, 2])` → `{a: 2}`, `createMapEntry('__proto__', 1)` (v0.7.0), `objOf('__proto__', 1)` (v0.18.0) and `indexBy(x => '__proto__', [1])` (v0.19.0) have no own key, the keys of `assoc('__proto__', 1, {a: 1})` (v0.8.0) are `['a']` (since v0.11.0 `assoc` and `dissoc` copy with a `for…in` loop, and an object value then becomes the result's prototype), `invertObj({a: '__proto__', b: 'c'})` (v0.9.0) → `{c: 'b'}`, `evolve({toString: x => typeof x}, {})` passed the inherited member from v0.9.0 to v0.14.0 (→ `{toString: 'function'}`; since v0.15.0 `{}`, as here), and since v0.15.0 an own key of the object that names a member finds the transformations' inherited member and is transformed by it (`evolve({a: f}, {toString: 4})` → `{toString: '[object Undefined]'}`; an own `valueOf` throws `TypeError`), `pick(['toString'], {})` (v0.15.0, `names[idx] in obj`) has the inherited function as its `toString`, `invert({a: '__proto__', b: 'x'})` (v0.10.0) → `{x: ['b']}`, its prototype set to `['a']` (in v0.9.x it and any other of the 12 names threw `TypeError: out[val].push is not a function`; since v0.10.0 the others are ordinary keys, as here), and `groupBy(x => '__proto__', [1, 2])` throws `RangeError` (`groupBy` and `countBy` did all this before v0.3.0 as well). Every function that copies properties by assignment drops an own `__proto__` property, which only `JSON.parse` or `Object.defineProperty` can create: `clone` (`cloneObj` from v0.5.0 and `cloneDeep` in v0.8.0, which v0.9.0 merged into it), `merge` (`mixin` until v0.9.1) and `mergeWith`/`mergeWithKey` (v0.19.0) of `JSON.parse('{"__proto__": 5, "a": 1}')` → `{a: 1}`, and `mapObj`, `mapObjIndexed`, `pick`, `pickAll`, `pickBy`, `omit`, `assoc` (v0.8.0), `evolve` (v0.9.0), `mergeAll` and `dissoc` (v0.10.0), `project`, and `lensProp`'s setter (v0.14.0, `assoc`; the keys of `lensProp('__proto__').set(1, {a: 1})` were `['a']`, and since v0.16.0 those of `set(lensProp('__proto__'), 1, JSON.parse('{"__proto__": 0, "a": 1}'))` are) likewise; `whereEq` (v0.14.0) tests the spec through `mapObj`'s copy, so an own `__proto__` spec property is not tested (`whereEq(JSON.parse('{"__proto__": 1}'), {})` → `true`). (From v0.9.0 to v0.13.0 `sort` sorted deep copies of the elements and dropped it from each element object, an omission of the v0.9.0 port; since v0.14.0 it sorts a shallow copy, as `sortBy` has since v0.10.0, as here.) A read of a member's name that the object lacks finds the inherited member (an omission of the earlier ports, recorded in v0.15.1): `prop('toString', {})` is the inherited function (since v0.1.0, as was `get('toString', {})`, its alias until v0.12.0), and so is the value for that name in `props(['toString'], {})` (v0.8.0; also in the earlier `props(obj, p)`, `propOf` from v0.8.0 until v0.12.0), `pluck('toString', [{}])`, `pickAll(['toString'], {})` and `project(['toString'], [{}])` (since v0.1.0); and `where` calls a spec function with it (since v0.1.1, except in v0.2.3, which tested for an own property): `where({toString: x => x === undefined}, {})` → `false` (since v0.14.0; from v0.2.4 to v0.13.0, when the port required the property, `where({toString: () => true}, {})` → `true`), and so does `propSatisfies` (v0.16.0: `propSatisfies(x => x === undefined, 'toString', {})` → `false`). | every key is ordinary (`evolve` transforms only obj's keys that have a transformation, `pick` takes only obj's keys): `map["hasOwnProperty" := [1]]`, `map["__proto__" := 2]`, `map["__proto__" := 1, "a" := 2]`, and the copies keep `"__proto__"`; the throw is not modeled; a read of a name the map lacks is `None` (`prop`, `props`, `pluck`; `pickAll` and `project` map the name to `None`), and `where`'s and `propSatisfies`'s predicates get `None` | A `map` has no prototype. |
| `reduce`, `mergeAll`, `mapObj` (until v0.18.0), `mapObjIndexed`, `groupBy` | since v0.12.0 `_reduce` speaks the transducer protocol (and `reduced(x)`, v0.15.0, builds its marker): when the accumulator is truthy and has a truthy `@@transducer/reduced` property, the fold stops and returns its `@@transducer/value` (from v0.12.0 to v0.13.0 the keys were `__transducers_reduced__` and `value`, ordinary keys again since v0.14.0). `reduce((acc, x) => assoc('x', x, acc), {'@@transducer/reduced': 1, '@@transducer/value': 9}, [1, 2, 3])` → `9`, `mergeAll([{'@@transducer/reduced': 1, '@@transducer/value': 7}, {a: 2}])` → `7`, `mapObj(x => x, {'@@transducer/reduced': 1, '@@transducer/value': 5, z: 3})` and `mapObjIndexed` of it → `undefined`, and `groupBy(x => '@@transducer/reduced', [1, 2])` → `undefined` (and from v0.12.0 to v0.14.0 `evolve({'@@transducer/reduced': x => 1}, {a: 1})` → `{a: 1}`, through `mapObjIndexed`; since v0.15.0 evolve loops over the object's keys, as here) | `@@transducer/reduced` is an ordinary key: the fold runs to the end | A generic accumulator cannot single out the key; a `map` has no protocol. |
| `sortBy`, `maxBy`, `minBy` | compare keys with JS `<`/`>`, so string keys work: `sortBy(s => s, ["b", "a", "c"])` → `["a", "b", "c"]` | `int` keys | Dafny cannot order arbitrary key types, and overloading by key type is not possible. |
| `evolve`, `adjust`, `update`, `over`, `set_`, `when`, `unless` | a transformation may return a value of another type: `evolve({wow: String}, {})` (v0.9.0) → `{wow: 'undefined'}`, `adjust(String, 0, [1, 2])` (v0.14.0) → `['1', 2]`, `update(0, 'a', [1, 2])` (v0.14.0) → `['a', 2]`, `over(lensIndex(0), String, [1, 2])` and `set(lensIndex(0), 'a', [1, 2])` (v0.16.0) → `['1', 2]` and `['a', 2]`, and `when(x => x > 0, String, 3)` and `unless(isArrayLike, of)(10)` (v0.18.0) → `'3'` and `[10]` | `transformations: map<string, Option<V> -> V>`, `fn: T -> T`, `x: T`, the lens's focus type V and `when`'s and `unless`'s `T -> T`: one value type | Typed. |
| `mapSeq` (`map`), `ap`, `chain`, `complement`, `filter`, `reject` (and `both` and `either` in v0.18.0) | since v0.18.0 they take other functors: `map` maps an object's values (`map(dec, {x: 4, y: 5})` → `{x: 3, y: 4}`, which `mapObj` does) and composes with a function (`map(f, g)(10)` is `f(g(10))`); `ap` and `chain` take functions, the reader applicative and monad (`ap(f, g)(x)` is `f(x)(g(x))`, `chain(f, g)(x)` is `g(f(x))(x)`); and `both`, `either` and `complement` are `lift(and)`, `lift(or)` and `lift(not)`, so they combine any applicative's values (`both([true, false], [true])` → `[true, false]`, `complement([true, false])` → `[false, true]`; v0.19.0 makes `both` and `either` function combinators again); and since v0.19.0 `filter` and `reject` take an object, giving its own properties that pass (`filter(x => x > 1, {a: 1, b: 2})` → `{b: 2}`) | `mapSeq`, `filter` and `reject` take a list, `ap` and `chain` take lists, and `both`, `either` and `complement` take `T -> bool` predicates | Typed: one Dafny signature per function. |
| `sort`, `sortBy` | `Array.prototype.sort` puts `undefined` elements last without calling the comparator: `sortBy(x => x === undefined ? -1 : x, [1, undefined, 0])` → `[0, 1, undefined]` (since v0.9.1, which sorts the elements rather than key/value pairs, and still since v0.10.0's `_slice` copy; v0.9.0 gave `[undefined, 0, 1]`), and `sort` with the same key comparison → `[0, 1, undefined]` (always, and since v0.14.0 on a `_slice` copy too; an omission of the earlier ports) | `Undefined` is ordered like any other element: `[Undefined, Num(0), Num(1)]` with the key -1 | A generic `T` has no `undefined` to single out. |
| `sort` | an inconsistent comparator gives an engine-defined order: `sort(() => -1, [1, 2, 3])` → `[3, 2, 1]` | The postconditions say nothing for inconsistent comparators; the implementation (stable insertion sort) gives `[1, 2, 3]`. | ECMAScript leaves it unspecified. |
| string functions | count UTF-16 code units: `"😀".length` → `2`, `split('', "😀")` → two halves of a surrogate pair, and since v0.18.0 `reverse("a😀")` reverses the code units into an ill-formed string (`nthCharCode(0, "😀")` → `55357` until v0.18.0 removed `nthCharCode`, and `charCodeAt` until v0.14.0) | count code points: `1`, `["😀"]`, `"😀a"` | A Dafny `string` is a sequence of Unicode scalar values. |
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
(v0.19.1: `addIndex.js`, `binary.js`, `bind.js`, `call.js`, `composeK.js`, `construct.js`,
`constructN.js`, `curry.js`, `curryN.js`, `forEach.js`,
`into.js`, `lensPath.js`, `pathSatisfies.js`,
`invoker.js`, `is.js`, `isArrayLike.js`, `lift.js`, `liftN.js`, `pipeK.js`, `propIs.js`,
`partial.js`, `partialRight.js`, `match.js`, `memoize.js`, `nAry.js`,
`nthArg.js`, `once.js`, `path.js`, `pathEq.js`, `pathOr.js`, `dissocPath.js`,
`test.js`, `transduce.js`, `composeP.js`, `pipeP.js`, `tap.js`, `type.js`, `unapply.js`, `unary.js`,
`useWith.js`, `wrap.js`, `apply.js`, `assocPath.js`, `reduced.js`, `toString.js` and `uncurryN.js`; v0.10.0
renamed `lPartial.js`, `rPartial.js`, `pCompose.js` and `pPipe.js`, and
v0.11.0 removed `op.js` and `pathOn.js` and added `invariants.js` and
`internal/_curry2.js` and `internal/_curry3.js`, on currying and arity;
v0.12.0 removed `installTo.js` and added `test.js`, `transduce.js`,
`into.js` and `invoke.js`; v0.13.0 added `isNaN.js`; v0.14.0 removed
`func.js`, with the function, and added `toString.js` and `uncurryN.js`;
v0.15.0 removed `isNaN.js`, with the function, and added `addIndex.js` and
`reduced.js`; v0.16.0 removed `arity.js`, `forEachIndexed.js` and
`invoke.js`, with the functions, and added `composeK.js` and `pipeK.js`,
whose monad is an `Identity` object, and `propIs.js`; v0.18.0 added
`pathOr.js`; v0.19.0 removed `functions.js` and `functionsIn.js`, with the
functions, and added `lensPath.js` and `pathSatisfies.js`).
`test.examplesRunner.js` (v0.5.0; in `test/helpers/` since v0.15.0) runs the JSDoc examples through `dox`
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
| v0.12.0 | 2015-03-21 | ported | — |
| v0.13.0 | 2015-03-22 | ported | — |
| v0.14.0 | 2015-05-11 | ported | — |
| v0.15.0 | 2015-06-14 | ported | — |
| v0.15.1 | 2015-06-21 | ported | — |
| v0.16.0 | 2015-07-12 | ported | — |
| v0.17.0 | 2015-07-19 | ported | — |
| v0.17.1 | 2015-07-21 | ported | — |
| v0.18.0 | 2015-10-11 | ported | — |
| v0.19.0 | 2015-12-21 | ported | — |
| v0.19.1 | 2016-01-03 | ported | — |
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

### v0.12.0 (2015-03-21)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, as the tree
  was re-indented; behaviour checked in node, with a differential run of the
  ported exports):
  - `and`, `or` and `not` become value operators, `a && b`, `a || b` and
    `!a` (`and(1, 0)` → `0`, `not('')` → `true`; `and(true, false)` was a
    function), and the predicate combinators they were move, with the same
    code, to the new `both`, `either` and `complement`.
  - `substring` is `slice` (`R.substring === R.slice`), so a string is cut
    with `String.prototype.slice` instead of `substring`: a negative index
    counts from the end and the indices are no longer swapped
    (`substring(3, 1, 'abcde')` → `''`, was `'bc'`; `substring(-2, 5,
    'abcde')` → `'de'`, was `'abcde'`). `substringFrom` (`substring(__,
    Infinity)`) and `substringTo` (`substring(0)`) follow
    (`substringFrom(-2, 'Ramda')` → `'da'`, `substringTo(-2, 'Ramda')` →
    `'Ram'`).
  - Transducers: `_reduce` stops when the accumulator carries a truthy
    `__transducers_reduced__` property and returns its `value`, which
    reaches `reduce`, `mergeAll`, `mapObj`, `mapObjIndexed`, `groupBy` and
    `evolve` on accumulators with that key; `all`, `any`, `drop`,
    `dropWhile`, `filter`, the `find` family, `groupBy`, `map`, `take` and
    `takeWhile` act as transducers when given a transformer in list
    position, and dispatch to a method of that name of a non-array.
  - New: `aperture(n, list)` (the windows of n consecutive elements),
    `none(fn, list)`, `nthChar(n, str)` and `nthCharCode(n, str)` (a negative
    n counts from the end), `both`, `either`, `complement`, and the
    unportable `into`, `transduce`, `invoke` and `test`.
  - Removed (deprecated in v0.11.0): `I`, `get`, `appendTo`, `prependTo`,
    `propOf` and `installTo`. Deprecated: `charAt`, `charCodeAt` (for
    `nthChar` and `nthCharCode`) and `func`.
  - Not visible in this encoding: `ifElse` reports the largest arity of its
    functions and is curried to it; `ap` and `commuteMap` call the
    exported, dispatching `ap` and `map` (Fantasy-land `Maybe` works in
    `commute`); `clone` copies a RegExp; `toPairs`, `toPairsIn` and
    `pickAll` are inline loops; `_reduce` folds iterators and objects with
    a `reduce` method.
- **Ramdaf:**
  - Removed `I`, `appendTo`, `prependTo` (Core), `get` and `propOf`
    (Object), with their tests and edge cases.
  - `and(a: bool, b: bool): bool`, `or` and `not(a: bool): bool` are the
    value operators, as v0.1.0 to v0.1.3 had them (breaking); `both`,
    `either` and `complement` (Logic) take the predicate combinators'
    bodies.
  - `substring` writes `List.slice`'s clamping out on the string (String
    imports nothing); `substringFrom` and `substringTo` keep their bodies,
    which call it (all three breaking).
  - Added `aperture` (`n: int`; for n <= 0 `|list| - n + 1` empty windows,
    as node gives) and `none` (`!any(fn, list)`) in List, and `nthChar` and
    `nthCharCode` (built-in bodies, as Ramda calls the native methods;
    `nthCharCode` requires the index to fall in the string) in String.
  - "Not portable": `installTo` leaves; `test` joins `match`, `invoke`
    joins `invoker`/`func`, and `into` and `transduce` get a transducer
    row.
  - "Outside the modeled domain": `nthCharCode` joins `charCodeAt`.
  - Deviations: a new Typed row for the value operators `and`, `or` and
    `not`; the deciding-operand and fixed-arity rows move to `both`,
    `either` and `complement`; a new row for the `__transducers_reduced__`
    marker in `reduce`, `mergeAll`, `mapObj`, `mapObjIndexed`, `groupBy` and
    `evolve`, pinned by `DeviationReducedMarkerIsAnOrdinaryKey` (in each
    edge file).
  - Comments only: `charAt`, `charCodeAt` (deprecated), `reduce`,
    `mapObj`, `mapObjIndexed`, `groupBy`, `evolve`, `props`.
  - Tests: both.js, either.js and complement.js (the old and/or/not
    `it`s), the bool lines of the new and.js, or.js and not.js (their number,
    string and array operands are not bool), aperture.js, none.js,
    nthChar.js, nthCharCode.js, the substring family's "accepts negative
    offsets" and map.js's "composes"; prependTo.js, appendTo.js, propOf.js
    and the `I`/`get` alias `it`s go. Not transcribed: the transducer, `into`
    and dispatch `it`s, ifElse's arity, clone's RegExp, and commute's
    `Maybe`. The substring edges follow slice (`SubstringIsSlice`), and new
    edges cover `aperture`, `none`, `nthChar` and the boolean operators.
- **Expected tier: major.** `I`, `appendTo`, `prependTo`, `get` and `propOf`
  were removed; `and`, `or` and `not` changed signature and `substring`,
  `substringFrom` and `substringTo` results; seven symbols were added
  (`casestudy/expected/v0.12.0.json`).
- **lem:** — (not yet published from this history).

### v0.13.0 (2015-03-22)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, behaviour
  checked in node; most of it is JSDoc and test style):
  - New: `isNaN(x)` (`typeof x === 'number' && x !== x`, `@category Math`).
  - `invoke(methodName, args, obj)` takes the object last (it was
    `invoke(methodName, obj, args)`).
  - Not visible in this encoding: JSDoc wording and examples; the tests
    retitle 57 "is automatically curried"/"is properly curried" `it`s "is
    curried" and write `assert(…)` as `assert.strictEqual(…, true)`, with the
    same values. A differential run of the ported exports finds no change.
- **Ramdaf:** no source or test change beyond comments; the headers cite
  v0.13.0.
  - "Not portable": `isNaN` joins the run-time type row (NaN is not an
    `int`, so a port would be the constant `false`); the `invoke` text
    follows its new argument order.
  - Tests: the unportable isNaN.js joins the header lists.
- **Expected tier: patch.** No Dafny-visible change
  (`casestudy/expected/v0.13.0.json`, with no changes).
- **lem:** — (not yet published from this history).

### v0.14.0 (2015-05-11)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, every
  changed module compared in normalised form, behaviour checked in node with
  a differential run of the ported exports):
  - `where` calls every own spec property as a predicate with the test
    object's property alone, `undefined` when it is absent (9e540f16): a
    value entry now throws `TypeError` (`where({a: 1}, {a: 1})`, was `true`),
    and a predicate on an absent property is called (`where({a: x => x ===
    undefined}, {})` → `true`, was `false`). The value entries move to the
    new `whereEq(spec, testObj)`, `where(mapObj(eq, spec), testObj)`.
  - `differenceWith` pushes its kept elements again (f5966efd), undoing
    v0.11.0's holes: `differenceWith(eq, [1, 2, 3, 4], [2])` → `[1, 3, 4]`.
  - `drop` treats a negative n as zero, `n <= 0 ? list : _slice(list, n)`:
    `drop(-1, [1, 2])` → `[1, 2]` (was `[undefined, 1, 2]`).
  - The private `_eq` (`Object.is`, `eq`'s body) replaces `===` in
    `_indexOf` and `_lastIndexOf` (so `contains`, `indexOf`, `lastIndexOf`,
    `isSet`, `difference` and `intersection`), `propEq` and `eqProps`, and
    `uniq` becomes `uniqWith(eq)` (and with it `union`): only `-0` and `NaN`
    differ (`contains(-0, [0])` → `false`, `uniq([0, -0])` → `[0, -0]`).
  - `sort` sorts `_slice(list)` instead of a deep `clone(list)` ("Don't
    clone in sort"): a JS string sorts again (`sort(cmp, 'cab')` → `['a',
    'b', 'c']`), and element objects keep their identity and an own
    `__proto__` key.
  - The transducer protocol's keys become `@@transducer/init`,
    `@@transducer/step`, `@@transducer/result`, `@@transducer/reduced` and
    `@@transducer/value`, so the folds stop on an accumulator with a truthy
    `@@transducer/reduced` (and `__transducers_reduced__` is an ordinary key
    again).
  - New: `adjust`, `update`, `intersperse`, `dropRepeats`,
    `dropRepeatsWith` and `lensIndex` (`@category List`), `lensProp` and
    `whereEq` (Object), `composeL` and `pipeL` (Function), `mean` and
    `median` (Math), and the unportable `toString` (String) and `uncurryN`
    (Function). Removed: `charAt`, `charCodeAt` and `func` (deprecated in
    v0.12.0). `isNaN` is `@deprecated`.
  - Not visible in this encoding: `and` and `or` dispatch to an `and`/`or`
    method of the first argument; `converge`'s result is curried to its
    longest function's arity and passes `this`; `take` relies on `_slice`'s
    new clamping, with the same results; `pluck` maps with the exported,
    dispatching `map`; `memoize` keys its cache by `R.toString`; `pathEq`
    compares with `Object.is` and `path([], obj)` is `obj`; `lensOn`'s JSDoc
    puts the object last, and `mapObjIndexed`'s says `@category Object`.
- **Ramdaf:**
  - `where(spec: map<string, Option<V> -> bool>, test)` is `forall k :: k
    in spec ==> spec[k](prop(k, test))` (breaking), and `Prelude.SpecVal`
    is removed; the new `whereEq<V(==)>(spec: map<string, V>, test)` is
    `where` of a map comprehension of `eq` (Object does not import List's
    `mapObj`).
  - `differenceWith` drops v0.11.0's kept-prefix precondition, with its
    v0.10.0 body (compatible), and `drop` takes `n: int` and gives the list
    for `n <= 0` (compatible); their "Outside the modeled domain" rows go.
  - Removed `charAt` and `charCodeAt` (String).
  - Added `adjust`, `update` (`adjust` of `_ => x`), `intersperse`,
    `dropRepeatsWith`, `dropRepeats` (`dropRepeatsWith` of `==`) and
    `lensIndex` (List); `lensProp` and `whereEq` (Object); `composeL` and
    `pipeL` (Functions, binary, which now imports Prelude); `mean` and
    `median` (Math, returning `real`; Math now imports Sort, and `median`
    sorts with `Sort.sort`). The lens functions' arrows are partial (D11):
    `lensIndex(n)`'s getter requires the index in the list and its setter
    `n >= -1`, `lensProp(k)`'s getter requires the key, and a composed lens
    requires what its parts do. `lensProp` and `composeL` write `lens`'s
    body out, as Object and Functions do not import List.
  - `uniq` keeps its own recursion (Ramda's `uniqWith(eq)` gives the same
    results), as `head` and `last` did when v0.8.0 wrote them on `nth`.
  - "Not portable": `func` leaves; `uncurryN` joins `curry`/`curryN` and
    `toString` the run-time type row; the `memoize`, `path`, `into` and
    `isNaN` texts follow.
  - "Outside the modeled domain": `drop` and `differenceWith` leave,
    `charCodeAt` leaves `nthCharCode`'s row, `where`'s row moves to
    `whereEq`, and `lensIndex`, `lensProp`, `composeL`/`pipeL` and
    `mean`/`median` get rows.
  - Deviations: the signed-zero row gains every function that compares with
    `Object.is` since v0.14.0 (pinned in each edge file), and the reference
    row `whereEq` and `dropRepeats`; the `sort`-on-a-string row retires (node
    agrees), and so does `sort`'s part of the `__proto__` row, which gains
    `lensProp` and `whereEq`; the reduced-marker row takes the new keys;
    `composeL`/`pipeL` join the `compose`/`pipe` row and, with `lensIndex`
    and `lensProp`, the `lens` row; `adjust` and `update` join `evolve`'s
    Typed row; `converge`'s row notes its curried result. The mapping's
    `where`, lens and number rows follow.
  - Comments only: `contains`, `indexOf`, `lastIndexOf`, `isSet`, `uniq`,
    `propEq`, `eqProps`, `take`, `pluck`, `sort`, `and`, `or`, `converge`,
    `lensOn`, `mapObjIndexed`, and the reduced-marker notes of `reduce`,
    `mapObj`, `evolve` and `groupBy`; the headers cite v0.14.0.
  - Tests: where.js rewritten for predicates (with "matches specs that have
    undefined properties" over Js values), the new whereEq.js, adjust.js,
    update.js, intersperse.js, dropRepeats.js, dropRepeatsWith.js,
    lensIndex.js, lensProp.js, composeL.js, pipeL.js, mean.js and median.js,
    converge's "returns a curried function", drop's "returns an equivalent
    list if `n` is <= 0", and the "sparse array" `it`s of difference and
    differenceWith, whose witness asserts go; charAt.js and charCodeAt.js go
    with the functions. Not transcribed: the "has Object.is semantics"
    `it`s (no `-0` or NaN in an int), the dispatch, transducer, arity,
    `this`, array-like and prototype `it`s, and toString.js and uncurryN.js.
    The pins `DeviationSortOfAString` and the `sort` line of
    `DeviationPrototypeKeysAreOrdinaryInSortedCopies` become the agreement
    edges `SortOfAString` and `SortKeepsPrototypeNamedKeys`; the
    reduced-marker pins take the new keys, with agreement edges
    `OldReducedMarkerIsAnOrdinaryKey` for the old one; new pins
    `DeviationListSearchesSignedZero` and `DeviationSetOperationsSignedZero`,
    and `DeviationEqSignedZero` and the `__proto__` pin gain lines; new
    edges cover the new functions, `drop` with a negative n and
    `differenceWith` past v0.11.0's domain.
- **Expected tier: major.** `charAt`, `charCodeAt` and `Prelude.SpecVal`
  were removed and `where` changed signature; `differenceWith` and `drop`
  accept more input with every previous result unchanged (compatible); 12
  symbols were added (`casestudy/expected/v0.14.0.json`).
- **lem:** — (not yet published from this history).

### v0.15.0 (2015-06-14)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, every
  changed module compared in normalised form, behaviour checked in node with
  a differential run of the ported exports; most of the diff is a lint pass
  replacing `++`/`--` loops, which the run shows equivalent except in
  `_createMaxMinBy`):
  - `maxBy` and `minBy` start their loop from `winner = list[1]` (7f7648df,
    the lint pass), so `list[0]` is never considered: `maxBy(x => x, [9,
    1])` → `1` (was `9`), and a one-element list calls `keyFn(undefined)`:
    `maxBy(x => x * 2, [5])` → `undefined`, `maxBy(prop('x'), [{x: 1}])`
    throws. Ramda's own tests are unaffected.
  - `take` is `slice(0, n < 0 ? Infinity : n, xs)`: a negative n takes the
    whole list (`take(-1, [1, 2, 3])` → `[1, 2, 3]`, was `[]`); `drop` is
    `slice(Math.max(0, n), Infinity, xs)`, with the same results. Both call
    the exported `slice`, so a JS string gives a string.
  - `evolve` loops over the object's own keys: a transformation for a key
    the object lacks is no longer called (`evolve({n: add(1)}, {})` → `{}`,
    was `{n: NaN}`), an object transformation is applied recursively ("is
    recursive"), any other value leaves the property, and an own key naming
    an `Object.prototype` member is transformed by the transformations'
    inherited member.
  - `eq` and `eqDeep` are removed for the new `identical` (`Object.is`) and
    `equals` (deep equality, dispatching to an `equals` method), both
    `@category Relation`. `contains`, `indexOf`, `lastIndexOf`, `isSet`,
    `difference`, `intersection`, `propEq`, `eqProps`, `whereEq`,
    `dropRepeats` and `pathEq` compare with `equals`, so objects compare
    deeply (`contains({a: 1}, [{a: 1}])` → `true`, was `false`); `uniq`
    keeps a JS `Set` (by reference, but `equals` for `0`, `-0` and objects
    with an `equals` method). `-0` still differs from `0` everywhere.
  - `pick` loops over the names with `names[idx] in obj`, so a name of an
    `Object.prototype` member picks the inherited member.
  - New: `equals`, `identical`, and the unportable `addIndex` and `reduced`.
    Removed: `isNaN` (not portable).
  - Not visible in this encoding: `chain` is a transducer and dispatches
    through `_dispatchable`; `indexOf`, `lastIndexOf` and `forEach` dispatch
    to a non-array's method; `propOr` accepts a null object; `keys` of a
    primitive is `[]`; the placeholder is `{'@@functional/placeholder':
    true}` and `curryN` is rewritten on `_curryN`; `invoker(arity, method)`
    takes no initial arguments; `arity` drops its `void` statements.
- **Ramdaf:**
  - `maxBy` and `minBy` follow the new loop (the first element with the
    greatest key among `list[1..]`) and require `|list| != 1` (breaking).
  - `take` is `slice(0, if n < 0 then |list| else n, list)` (breaking), and
    `drop` `slice(if n < 0 then 0 else n, |list|, list)` (compatible), as
    Ramda calls `slice`.
  - `evolve` maps the object's keys, `if k in transformations then
    transformations[k](prop(k, obj)) else obj[k]` (breaking); the
    transformations keep their `Option<V> -> V` type and now always get
    `Some`.
  - Removed `eq` (Object) and `eqDeep` (Data); added `equals` and
    `identical` (Data, by `@category Relation`; both `==`). `whereEq` writes
    `equals` out as `==` (Data imports Object), with the same results
    (compatible).
  - `uniq` keeps its own recursion (its results on Dafny values are the
    same).
  - "Not portable": `isNaN` leaves the run-time type row; `addIndex` joins
    `memoize`/`once` (hidden mutable state) and `reduced` the transducer
    row; the `__` and `invoker` texts follow.
  - "Outside the modeled domain": new rows for `maxBy`/`minBy` (a
    one-element list) and `evolve` (nested and non-function
    transformations).
  - Deviations: the reference-equality row narrows to `identical`, `uniq`
    and `union` (node now compares the others deeply, as here); the
    signed-zero row takes `identical` and `equals`; the `__proto__` row
    gains `pick`'s inherited names and `evolve`'s inherited transformations
    and loses `evolve`'s old inherited-member case; `evolve` leaves the
    reduced-marker row, which notes `reduced`. The mapping's placeholder
    text follows.
  - Comments only: `contains`, `indexOf`, `lastIndexOf`, `isSet`, `uniq`,
    `dropRepeats`, `chain`, `eqProps`, `propEq`, `pick`, `propOr`, and the
    set functions' header; the headers cite v0.15.0.
  - Tests: equals.js (eqDeep.js's `it`s retargeted, with the new primitive
    `it`s) and the transcribable asserts of identical.js (eq.js's), in
    tests/ramda/sql.dfy; evolve's "does not invoke function if object does
    not contain the key"; take's negative n and the string lines of take's,
    drop's, indexOf's and lastIndexOf's dispatch `it`s; chain.js's rewritten
    `it`s ("does not flatten recursively" over Js values); uniq's "handles
    null and undefined elements"; pick's "handles numbers as properties"
    (the key "1"); where.js's `R.equals`. Not transcribed: the "has
    R.equals semantics" `it`s (`-0`, NaN, objects with an `equals` method),
    evolve's "is recursive", the boxed-primitive, dispatch, transducer,
    reference and arity `it`s, propOr's nil object, and addIndex.js and
    reduced.js. The `maxBy`/`minBy` lambdas in tests require `|l| != 1`.
    Edge changes: `maxBy`/`minBy` and `take` expectations follow node;
    `DeviationEqIsStructural` and `DeviationEqSignedZero` become
    `DeviationIdenticalIsStructural` and `DeviationIdenticalSignedZero`,
    `EqDeepEdges` and `DeviationEqDeepSignedZero` `EqualsEdges` and
    `DeviationEqualsSignedZero`; `DeviationStructuralEquality` keeps only
    `union`, with the agreement edge `SetOperationsCompareDeeply`; the
    `evolve` reduced-marker pin becomes the agreement edge
    `EvolveIgnoresTheReducedMarker`; the `__proto__` pin gains `pick` and
    `evolve` lines.
- **Expected tier: major.** `eq` and `eqDeep` were removed; `take`,
  `maxBy`, `minBy` and `evolve` changed results (and `maxBy`/`minBy` gained
  a precondition); `drop` and `whereEq` have rewritten revealed bodies with
  the same results (compatible); `equals` and `identical` were added
  (`casestudy/expected/v0.15.0.json`).
- **lem:** — (not yet published from this history).

### v0.15.1 (2015-06-21)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, every
  changed module compared in normalised form, behaviour checked in node with
  a differential run of the ported exports; most of the diff reverts
  v0.15.0's removal of array length caching, 128c2cca, which the run shows
  equivalent):
  - `lensIndex(n)` is `lens(nth(n), update(n))` (77d7863a): the setter
    replaces the element at n, a negative n counting from the end, and
    leaves the list out of range (`lensIndex(5).set(9, [1, 2])` → `[1, 2]`,
    was `[1, 2, 9]`; `lensIndex(-1).set(9, [1, 2])` → `[1, 9]`, was `[9, 1,
    2]`; `lensIndex(-2).set(9, [1, 2])` → `[9, 2]`, was `[9, undefined, 1,
    2]`). The getter is unchanged.
  - `eq` and `eqDeep` return, `@deprecated since v0.15.0` and `@category
    Relation` ("Deprecate `eq` and `deepEq`"): `eq` is `_curry2(_eq)`, with
    the private `_eq` (`Object.is`) restored, and `eqDeep` is `equals`
    itself.
  - `uniq` is `uniqWith(equals)` again (4b417682 reverts v0.15.0's `Set`
    loop): `uniq([{a: 1}, {a: 1}])` → `[{a: 1}]` (both were kept), and
    through it `union(Ro, So).length` → `6` (was `8`).
  - `maxBy`/`minBy` are unchanged: `_createMaxMinBy` still starts at
    `list[1]`.
  - Not visible in this encoding: the cached lengths (only a callback that
    mutates the list could tell); `lensProp` and `lensIndex` are
    `_curry1`; JSDoc for `commute`, `commuteMap`, `slice`, `take`, `drop`,
    `sortBy`, `merge` and `isEmpty`; the dispatch `it`s of `into`,
    `reduce` and `transduce` drop lodash.
- **Ramdaf:**
  - `lensIndex`'s setter is `update(n, x, xs)`, as Ramda calls `update`
    (breaking); it no longer requires `n >= -1`, and the getter and `map_`
    keep their precondition.
  - Added `eq` (`a == b`) and `eqDeep` (`equals(a, b)`, an alias) in Data,
    by `@category Relation` (`eq` was in Object until v0.14.0; a removed
    name that returns is a new function), with deprecation comments.
  - `uniq` keeps its own recursion (its results on Dafny values are the
    same); comments only, with `prop`, `props`, `pickAll`, `pluck`,
    `project`, `where`, `equals` and `identical`; the headers cite v0.15.1.
  - "Outside the modeled domain": `lensIndex`'s row keeps the getter and
    records the setter's dropped precondition.
  - Deviations: the reference row narrows to `identical` and `eq` (node now
    compares `uniq` and `union` deeply, as here); `eq` and `eqDeep` join the
    signed-zero row; the `__proto__` row gains the inherited-member reads of
    `prop`, `props`, `pickAll`, `pluck`, `project` and `where`, an omission
    of the earlier ports (since v0.1.0 for most; recorded now, as v0.9.1
    recorded `sort`'s owed rows).
  - Tests: eq.js's "has Object.is semantics" (`EqHasObjectIsSemantics`)
    and eqDeep.js's five transcribable `it`s again (`EqDeep*`, as at
    v0.14.0), in tests/ramda/sql.dfy, and uniq's new `[[1], [1]]` line.
    Not transcribed: eq.js's NaN and `new Number` lines and its "is curried"
    (reference), and the dispatch `it`s. `LensIndexEdges` follows node's
    `update` setter; the pin `DeviationStructuralEquality` becomes the
    agreement edge `UniqAndUnionCompareDeeply`; `DeviationIdenticalIsStructural`
    and `DeviationIdenticalSignedZero` gain `eq` lines,
    `DeviationEqualsSignedZero` an `eqDeep` line and `EqualsEdges` both;
    the new pin `DeviationInheritedMembersAreAbsent` covers the
    inherited-member reads.
- **Expected tier: major.** `lensIndex`'s setter changed results; `eq` and
  `eqDeep` were added (`casestudy/expected/v0.15.1.json`).
- **lem:** — (not yet published from this history).

### v0.16.0 (2015-07-12)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, every
  changed module compared in normalised form, behaviour checked in node with
  a differential run of the ported exports):
  - Lenses become van Laarhoven functions (2d0b0270, "composable lenses"):
    `lens(getter, setter)` is `f => s => map(v => setter(v, s),
    f(getter(s)))`, without `set` and `map` properties (`lens(g, s)(a)` is a
    function), run by the new `view(lens, x)`, `over(lens, f, x)` and
    `set(lens, v, x)` (`over(lens, always(v), x)`, so it runs the getter
    too) with their private `Const` and `Identity` functors, and composed
    with `compose` and `pipe`; `lensIndex` and `lensProp` keep their getter
    and setter. `composeL`, `pipeL` and `lensOn` are removed.
  - `max(a, b)`, `min(a, b)`, `maxBy(f, a, b)` and `minBy(f, a, b)` are
    binary (43b57125): `max([3, 1])` is now a function, `max(1, 2)` → 2,
    `maxBy(n => n * n, -3, 2)` → -3 (a tie keeps the first).
  - `propEq(val, name, obj)` takes the value first,
    `propSatisfies(equals(val), name, obj)`: `propEq('b', 2, {b: 2})` →
    `false`, `propEq(2, 'b', {b: 2})` → `true`.
  - `cond` takes its pairs as one list, `cond([[p, f], …])`, as the port
    always has (f5558cba).
  - `nth` on a string gives `charAt`, `''` out of range, and with it
    `head('')` and `last('')` → `''` (81534adb); `empty` gives `{}` for an
    object, `''` for a string and `undefined` for anything else, and calls
    a constructor's `empty` (5e88dcda); `commute` is `commuteMap(identity)`.
  - Removed (1a2e129b, deprecated since v0.15.0): `mapIndexed`,
    `filterIndexed`, `rejectIndexed`, `reduceIndexed`,
    `reduceRightIndexed`, `substring`, `substringFrom`, `substringTo`,
    `strIndexOf`, `strLastIndexOf`, `eq`, `eqDeep`, and the unportable
    `arity`, `forEachIndexed` and `invoke`.
  - New: `dropLast`, `dropLastWhile`, `takeLast`, `takeLastWhile`,
    `splitEvery` (throws for n ≤ 0) and `uniqBy` (`@category List`),
    `propSatisfies` (Logic), `composeK` and `pipeK` (Kleisli composition
    with `chain`, Function), `view`, `over` and `set` (Object), and the
    unportable `propIs`.
  - Not visible in this encoding: "reduce the number of internal
    functions" deletes private helpers, inlining most into their exported
    functions with the same results; `insert` splices into a copy; `range` throws for
    non-numbers; `tail` is `slice(1, Infinity)`; `compose` is `pipe`
    reversed, `pipe` curries its result to the first function's arity, and
    both throw without functions; `converge` and `allPass` use `Math.max`;
    `take(0)` as a transducer ends at once.
- **Ramdaf:**
  - Lenses follow Ramda (D13): `Prelude.Lens<S, V, X>` is the type `(V -->
    Functor<X, V>) -> (S --> Functor<X, S>)`, with the new datatype
    `Prelude.Functor<X, T> = Const(c) | Identity(v)` and its map
    `Prelude.map_`; `lens<S, V, X>(getter, setter)`, `lensIndex<T, X>(n)`
    and `lensProp<V, X>(k)` return such functions (breaking, with
    `Prelude.Lens`), and `lens` writes `map_` out as its match (Dafny does
    not unfold a call inside the returned lambda). Added `view`, `over` and
    `set_` (Object; `set` is a keyword), which require the lens's
    precondition and, for `view` and `over`, the matching functor; lenses
    compose with `Functions.compose`. Removed `composeL`, `pipeL`, `lensOn`
    and `Prelude.LensOn`.
  - `max`, `min`, `maxBy` and `minBy` are binary, and `propEq` takes
    `(val, name, obj)` (breaking); Math no longer imports Prelude.
  - Removed the five `*Indexed` functions (List), `substring`,
    `substringFrom`, `substringTo`, `strIndexOf` and `strLastIndexOf`
    (String), and `eq` and `eqDeep` (Data). `replace` finds the first
    occurrence through `split`, and `split` recurses on a prefix match, as
    neither may name `strIndexOf` (compatible: rewritten revealed bodies,
    same results); `commute` is `commuteMap(xs => xs, …)` (compatible).
  - Added `dropLast` (`take`), `takeLast` (`drop`), `dropLastWhile`,
    `takeLastWhile`, `splitEvery` (calls `slice`; `requires n > 0`) and
    `uniqBy` in List, `propSatisfies` in Logic (`prop` written out), and
    `composeK` and `pipeK` in Functions, binary and over lists through
    `List.chain` (Functions imports List).
  - Comments only: `nth`, `head`, `last`, `tail`, `empty`, `insert`,
    `cond`, `compose`, `pipe`, `converge`, `equals`, `identical`; the
    headers cite v0.16.0. The deprecation of the ten ported functions
    removed here (since v0.15.0) was owed to the v0.15.0 port's comments.
  - "Not portable": `arity`, `forEachIndexed` and `invoke` leave their
    rows, and `propIs` joins `is`.
  - "Outside the modeled domain": the `max`/`min` and `maxBy`/`minBy`
    rows go; `lensIndex` and `lensProp` record that `set` runs the getter
    (their lenses require the index or key throughout); the `composeL` row
    becomes composed lenses; new `splitEvery` row; `head`/`last` note `''`.
  - Deviations: the `cond`, `*Indexed` and `lensOn` rows retire; the
    `compose` row takes `composeK`/`pipeK`, the `commute` row
    `composeK`/`pipeK` over lists, the lens row the van Laarhoven encoding,
    the Typed row `over` and `set_`; the reference and signed-zero rows
    drop `eq`/`eqDeep` and the latter gains `uniqBy`; the `__proto__` row
    gains `propSatisfies`; `empty`, `max` and `allPass` texts follow. The
    mapping's lens, "no value" and index-callback rows follow.
  - Tests: lenses.js's three `it`s (the composed lens over alice's address
    alone, as its name cannot share the map's value type), the binary
    max/min/maxBy/minBy `it`s, propEq's swapped `it`s, the string lines of
    head, last, nth, init, tail, slice, take and drop, empty's array and
    string `it`s, compose's and pipe's "performs right-to-left
    (left-to-right) function composition", and the new dropLast.js,
    takeLast.js, dropLastWhile.js, takeLastWhile.js, splitEvery.js,
    uniqBy.js and propSatisfies.js; the tests of the removed functions go
    (lens.js, lensIndex.js, lensProp.js, lensOn.js, composeL.js, pipeL.js
    and the rest). Not transcribed: composeK.js and pipeK.js (an `Identity`
    monad), propIs.js, and the arity, curried-call, `-Infinity`,
    reference and throw `it`s. The lens edges run through `view`, `set_`
    and `over`, with composed lenses by `compose` and `pipe`; new edges
    cover the new functions, and the pins drop `eq`/`eqDeep` lines and gain
    `uniqBy` (signed zero) and `propSatisfies` (inherited members).
- **Expected tier: major.** 16 symbols were removed; `Prelude.Lens`,
  `lens`, `lensIndex`, `lensProp`, `max`, `min`, `maxBy`, `minBy` and
  `propEq` changed type; `commute`, `replace` and `split` have rewritten
  revealed bodies with the same results (compatible); 14 symbols were added
  (`casestudy/expected/v0.16.0.json`).
- **lem:** — (not yet published from this history).

### v0.17.0 (2015-07-19)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, behaviour
  checked in node with a differential run of the ported exports): one code
  change, b5f7ba1e "revert change to R.propEq argument order": `propEq(name,
  val, obj)` again, still `propSatisfies(equals(val), name, obj)`
  (`propEq('b', 2, {b: 2})` → `true`, `false` in v0.16.0). propEq.js
  returns to its v0.15.1 `it`s, and the `find` family's JSDoc examples
  follow.
- **Ramdaf:** `propEq(name: string, val: V, obj)` again (breaking: the
  parameter types change back); its tests and edges follow, and so does
  the signed-zero row's example; the headers cite v0.17.0 (the internal
  helpers' paragraph still cited v0.15.1, an omission of the v0.16.0
  port).
- **Expected tier: major.** `propEq` changed signature
  (`casestudy/expected/v0.17.0.json`).
- **lem:** — (not yet published from this history).

### v0.17.1 (2015-07-21)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, behaviour
  checked in node; a differential run of the ported exports finds no
  change): `match(rx, str)` is `str.match(rx) || []` (894c7fae, "fix
  R.match empty array default"; it was `compose(defaultTo([]),
  invoker(1, 'match'))`, whose `[]` default was one shared array), with
  new match.js `it`s; JSDoc only for `sortBy` (its example) and `test`.
- **Ramdaf:** no source or test change beyond comments; the headers cite
  v0.17.1. `match` is not portable (regular expressions).
- **Expected tier: patch.** No Dafny-visible change
  (`casestudy/expected/v0.17.1.json`, with no changes).
- **lem:** — (not yet published from this history).

### v0.18.0 (2015-10-11)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, every
  changed module compared in normalised form, behaviour checked in node with
  a differential run of the ported exports; most of `test/` moves from
  `assert` to `test/shared/eq.js`, which compares with `R.toString`, so `-0`
  and `0` now differ in the tests):
  - `commuteMap` folds with `reduceRight` and `prepend` (1502c6d5,
    7ef6df08), so the last list's element varies fastest:
    `commuteMap(map(add(10)), of, [[1, 2], [3, 4]])` → `[[11, 13], [11,
    14], [12, 13], [12, 14]]` (was `[[11, 13], [12, 13], [11, 14], [12,
    14]]`), and `commute` (`commuteMap(identity)`) with it.
  - `converge(after, fns)` takes the branching functions as one list
    (360d5904): `converge(mult, [add(1), add(3)])(2)` → `15`, while
    `converge(mult, add(1), add(3))(2)` now throws.
  - `allPass` and `anyPass` are curried to the longest predicate's arity
    (a599a531), so `allPass([])(3)` → `true` and `anyPass([])(3)` → `false`
    (both threw since v0.9.0), and `allPass(preds, v)` no longer applies at
    once (it ignores v).
  - Renames that keep the old name as a deprecated alias: `isSet` →
    `allUniq` (f28adc24) and `createMapEntry` → `objOf` (de2cc7e6), the
    same code. Removed (deprecated since v0.16.0): `nthChar` and
    `nthCharCode`. Deprecated: `containsWith`, `createMapEntry`, `isSet`,
    `mapObj`, `functions` and `functionsIn`.
  - New: `allUniq` and `pair(fst, snd)` (`[fst, snd]`, `@category List`),
    `objOf` and the unportable `pathOr(d, path, obj)` (`@category
    Object`), `eqBy(f, x, y)` (`equals(f(x), f(y))`, `@category Relation`),
    and `when(pred, f, x)` and `unless(pred, f, x)` (`@category Logic`).
  - Not visible in this encoding: `map` maps an object's values and
    composes with a function, `ap` and `chain` take functions, and `both`,
    `either` and `complement` are `lift(and)`, `lift(or)` and `lift(not)`
    (any applicative; on predicates the same results, without the
    short-circuit, which a pure predicate cannot observe); `and` and `or`
    no longer dispatch; `concat` is `flip(invoker(1, 'concat'))`
    (`concat([1], 2)` → `[1, 2]`, mixed types); `reverse` of a JS string is
    a string (the same Dafny seq; it reverses UTF-16 code units);
    `isEmpty` is `equals(x, empty(x))` (`isEmpty({})` → `true`);
    `defaultTo` defaults NaN; `clone` dispatches to a `clone` method;
    `equals` dispatches only when both sides agree, at any depth, and
    compares Maps, Sets and `arguments` objects; `unnest` is
    `chain(identity)`, `aperture` a transducer, `compose`'s and `pipe`'s
    results are not curried; `useWith`, `partial` and `partialRight` take
    lists, and `test` throws for a non-RegExp (not portable).
- **Ramdaf:**
  - `commuteMap` is `reduceRight` with `prepend` written out as `[y] + l`
    (List does not import Core), and `commute` follows (both breaking).
  - `converge(after, fns: (A -> B, A -> C))` takes the list as a pair (the
    mapping's pair row; breaking).
  - `allUniq` (List) takes isSet's body, and `isSet` is `allUniq(list)`
    (compatible, D1); `objOf` (Object) is `map[key := val]`, and
    `createMapEntry` keeps that body written out, as List does not import
    Object (no entry).
  - Removed `nthChar` and `nthCharCode` (String); their deprecation since
    v0.16.0 was owed to the v0.16.0 port's comments.
  - Added `pair` (List, a tuple), `eqBy` (Data, calling `equals`), and
    `when` and `unless` (Logic, `T -> T`).
  - "Not portable": `pathOr` joins the path row; the `useWith`,
    `partial`, `test` and `functions` texts follow.
  - "Outside the modeled domain": `nthCharCode`'s row goes.
  - Deviations: the `allPass([])` row retires (node agrees with the port),
    and the fixed-arity rows of `allPass`/`anyPass` and `converge` follow;
    a new Typed row for the other functors of `map`, `ap`, `chain`, `both`,
    `either` and `complement`; `when` and `unless` join the Typed
    transformation row, `objOf` the key-to-string and `__proto__` rows,
    `allUniq` and `eqBy` the signed-zero row; the `defaultTo` (NaN),
    `empty` (`arguments`) and string-function (`reverse`) texts follow. The
    mapping's pair row gains `pair` and `converge`.
  - Comments only: `containsWith`, `createMapEntry`, `isSet` and `mapObj`
    (deprecated), `mapSeq`, `ap`, `chain`, `unnest`, `reverse`,
    `aperture`, `isEmpty`, `clone`, `concat`, `and`, `or`, `both`,
    `either`, `complement`, `allPass`, `anyPass`, `defaultTo`, `equals`,
    `pipe`, `composeK`; the headers cite v0.18.0.
  - Tests: commute.js's and commuteMap.js's new orders; converge.js's
    list form as pairs; and.js's and or.js's bool truth tables (now
    every line); allPass's "returns true on empty predicate list",
    anyPass's "returns false for an empty predicate list" and the
    uncurried call of their "returns a curried function whose arity
    matches…" (a tuple), with "does not have to be curried" gone; compose's and pipe's rewritten "performs … function
    composition" (`compose(R.map, R.multiply, parseInt)`, with a local
    `parseInt` over a tuple); containsWith.js's rewritten `it`; reverse.js's
    arrays and strings; isEmpty's `' '` and `[[]]` lines; negate's `-0`
    lines (literally, an int has no `-0`); allUniq.js (isSet.js's `it`s,
    retargeted), pair.js, objOf.js, eqBy.js's first `it`, and when.js and
    unless.js over Js values. nthChar.js and nthCharCode.js go with the
    functions. Not transcribed: the function, object and `Maybe` functor
    `it`s of map, ap, chain and unnest, commute's sanctuary `Either` `it`s,
    the R.equals-semantics `it`s of allUniq and eqBy, equals.js's Map,
    Set, `arguments` and dispatch `it`s, clone's dispatch, empty's and
    isEmpty's `arguments` and object `it`s, defaultTo's NaN, aperture's
    transducer, and pathOr.js. The pin `DeviationAllPassOfTheEmptyList`
    becomes the agreement edge `AllPassOfTheEmptyList`;
    `DeviationCharactersAreCodePoints` swaps `nthCharCode` for `split` and
    `reverse`; the `__proto__` pin gains `objOf`, and the signed-zero pins
    `allUniq` and `eqBy`; the commute and converge edges follow node, and
    new edges cover `allUniq`, `pair`, `objOf`, `eqBy`, `when`, `unless`
    and `reverse` of strings.
- **Expected tier: major.** `nthChar` and `nthCharCode` were removed;
  `commuteMap`, `commute` and `converge` changed results or signature;
  `isSet`'s revealed body was rewritten (compatible); six symbols were
  added (`casestudy/expected/v0.18.0.json`).
- **lem:** — (not yet published from this history).

### v0.19.0 (2015-12-21)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, every
  changed module compared in normalised form, behaviour checked in node with
  a differential run of the ported exports; much of the diff is a lint
  pass, one `var` per line):
  - Removed (deprecated in v0.18.0): `containsWith`, `createMapEntry`,
    `isSet`, `mapObj`, and the unportable `functions` and `functionsIn`;
    `differenceWith` and `intersectionWith` call the private
    `_containsWith`, as `uniqWith` did. Deprecated: `commute` and
    `commuteMap` (for `sequence` and `traverse`).
  - `merge` is `mergeWith((l, r) => r)`, over the new `mergeWithKey`, with
    the same results.
  - `uniq` is `uniqBy(identity)`, and `uniqBy` keeps a JS `Set` of the keys
    that are primitives, with its own flag for a first `-0`, so a repeated
    `-0` is kept (`uniq([-0, -0])` → `[-0, -0]`, and `union` likewise), and a
    `null` key puts `null` in place of the element (`uniqBy(x => null, [1,
    2])` → `[null]`, was `[1]`).
  - `filter` and `reject` take an object as well (`filter(x => x > 1, {a:
    1, b: 2})` → `{b: 2}`), and `both` and `either` are the short-circuiting
    function combinators again (v0.18.0's `lift` forms took any
    applicative).
  - New: `indexBy`, `sequence`, `traverse`, `splitAt`, `splitWhen`,
    `transpose` and `without` (`@category List`), `symmetricDifference` and
    `symmetricDifferenceWith` (Relation), `mergeWith` and `mergeWithKey`
    (Object), `juxt` (Function), and the unportable `lensPath` (Object)
    and `pathSatisfies` (Logic), both on `path`.
  - Not visible in this encoding: `dropLast` and `dropLastWhile` are
    transducers; `_indexOf` uses the native `indexOf` for primitives, with
    the same results; `equals` compares `Error`s; `whereEq` maps the spec
    with `map`; the placeholder must be an object; `path`, `assocPath`,
    `memoize`, `once` and `useWith` change only in unportable ways.
- **Ramdaf:**
  - Removed `containsWith`, `createMapEntry`, `isSet` and `mapObj` (List),
    with their tests, edges and pin lines.
  - `uniqWith` (body and postcondition), `differenceWith` and
    `intersectionWith` write `containsWith` out, and `unionWith` follows
    `uniqWith`; `merge` is `mergeWith((l, r) => r, a, b)` (all compatible).
  - Added `indexBy`, `sequence`, `traverse` (arrays, as `commute`),
    `splitAt` and `splitWhen` (pairs), `transpose` and `without` (List),
    `symmetricDifference` and `symmetricDifferenceWith` (Data),
    `mergeWith` and `mergeWithKey` (Object), and `juxt` (Functions, unary).
  - "Not portable": `functions`/`functionsIn` leave (a note in the run-time
    type row); `lensPath` and `pathSatisfies` join the path row.
  - "Outside the modeled domain": a new `uniqBy` row for the `null` key
    (not expressible).
  - Deviations: the signed-zero row gains the repeated `-0` of `uniq`,
    `union` and `uniqBy`, and `without` and `symmetricDifference`; the
    functor row gains `filter`/`reject` on objects and keeps `both`/`either`
    as v0.18.0 history; the key rows gain `indexBy`, `mergeWith` and
    `mergeWithKey`, the Fantasy-land row `sequence` and `traverse`, the
    fixed-arity row `juxt`, and the mapping's pair row `splitAt` and
    `splitWhen`; the removed functions are marked "(until v0.18.0)".
  - Comments only: `commute`, `commuteMap` (deprecated), `filter`,
    `reject`, `uniq`, `uniqBy`, `dropLast`, `dropLastWhile`,
    `mapObjIndexed`, `mapSeq`, `whereEq`, `both`, `either`; the headers cite
    v0.19.0.
  - Tests: lensIndex.js and lensProp.js are back (view, set, over and the
    "well behaved lens" `it`s, lensIndex's over Js values; their undefined
    and add-a-property `it`s are outside the lens's domain, and lensProp's
    "can be composed" runs over `{a: {b: 1}}` alone); lenses.js's alice
    gains `pets` (its `lensPath` `it`s are not portable); the new
    indexBy.js, juxt.js (`()` and tuples), mergeWith.js, mergeWithKey.js,
    sequence.js and traverse.js (their list `it`s), splitAt.js,
    splitWhen.js, symmetricDifference.js, symmetricDifferenceWith.js,
    transpose.js (Js rows) and without.js (with the `[[1]]` line of "has
    R.equals semantics"); lastIndexOf's `lastIndexOf('x', [])`. Not
    transcribed: filter's and reject's "filters objects", indexOf's and
    lastIndexOf's function-identity `it`s, equals' `Error`s, and the
    dispatch, applicative and transducer `it`s. New edges cover the new
    functions; the signed-zero pins gain `uniq`, `union`, `uniqBy`,
    `without` and `symmetricDifference` lines and the `__proto__` pins
    `indexBy`, `mergeWith` and `mergeWithKey`; lenses.js's lensProp test
    needs one witness assert.
- **Expected tier: major.** `containsWith`, `createMapEntry`, `isSet` and
  `mapObj` were removed; `uniqWith`, `unionWith`, `differenceWith`,
  `intersectionWith` and `merge` have rewritten revealed bodies with the
  same results (compatible); 12 symbols were added
  (`casestudy/expected/v0.19.0.json`).
- **lem:** — (not yet published from this history).

### v0.19.1 (2016-01-03)

- **Ramda** (the whitespace-insensitive `src/` and `test/` diff, behaviour
  checked in node; a differential run of the ported exports finds no
  change): `times` throws `RangeError: n must be a non-negative number` for
  a negative n or NaN (it threw `RangeError: Invalid array length`);
  `clone` copies a Date by its time value, `equals` compares `Error`s by
  name and message alone, `keys` works around an enumerable
  `arguments.length` in old engines, and `toString` writes an invalid Date
  as `new Date(NaN)` (3be1d9dc, with a new toString.js line); the rest is
  JSDoc and packaging.
- **Ramdaf:** no source or test change beyond comments (`times`) and the
  "Outside the modeled domain" row of `repeat`/`times`; the headers cite
  v0.19.1.
- **Expected tier: patch.** No Dafny-visible change
  (`casestudy/expected/v0.19.1.json`, with no changes).
- **lem:** — (not yet published from this history).

## Toolchain

- Dafny 4.10 (lem-pinned) and the Lemmata package manager `lem`.
- `lem test` verifies `src/**/*.dfy`, then builds and runs `tests/**/*.dfy`
  together with it. The equivalent Dafny commands are:

  ```
  dafny verify src/*.dfy
  dafny test src/*.dfy tests/support.dfy tests/ramda/*.dfy tests/edge/*.dfy
  ```
