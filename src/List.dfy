// Ramdaf: Ramda v0.17.1 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "List Functions" section, except `comparator`/`sort`
// (Sort.dfy), `length` (Core.dfy) and `groupBy` (Data.dfy); from v0.9.0 on,
// the functions with `@category List` (`repeat`, `init`, `mapAccum`,
// `mapAccumRight`, `mergeAll`, `aperture`, `none`, `adjust`, `update`,
// `intersperse`, `dropRepeats`, `dropRepeatsWith`, `lensIndex`, `dropLast`,
// `dropLastWhile`, `takeLast`, `takeLastWhile`, `splitEvery`, `uniqBy` and the
// renamed functions below; since v0.16.0 the JSDoc of `lens` and
// `lensIndex` says `@category Object`, and functions do not move). (v0.4.1
// removed the aliases `drop`, `nth`, `flatMap`, `flattenDeep` and
// `flattenShallow`, and renamed `all`/`any` to their aliases `every`/`some`;
// v0.8.0 removed `xprodWith`. v0.9.0 removed `reduce` and `reduceRight`,
// whose aliases `foldl` and `foldr` held their code, and `indexOf.from`,
// `lastIndexOf.from` and `slice.from`; it renamed the `.idx` properties to
// `*Indexed` functions, `skip` to `drop`, `every`/`some` to `all`/`any` and
// `insert.all` to `insertAll` (the name the port already used), and replaced
// `skipUntil` with `dropWhile`. v0.10.0 renamed `foldl`, `foldr`,
// `foldlIndexed`, `foldrIndexed`, `mapAccumL`, `mapAccumR`, `scanl` and
// `unfoldr` to `reduce`, `reduceRight`, `reduceIndexed`,
// `reduceRightIndexed`, `mapAccum`, `mapAccumRight`, `scan` and `unfold`,
// with the same code. v0.16.0 removed `mapIndexed`, `filterIndexed`,
// `rejectIndexed`, `reduceIndexed` and `reduceRightIndexed`, deprecated
// since v0.15.0 for `addIndex`, which is not portable.)

module Ramdaf.List {
  import opened Prelude

  export
    reveals reduce, reduceRight, unfold, mapSeq,
            mapObj, mapObjIndexed, filter, reject,
            takeWhile, take, dropWhile, drop, find, findIndex, findLast, findLastIndex,
            all, any, contains, containsWith, uniq, isSet, uniqWith, pluck, flatten,
            zipWith, zip, lens, xprod, reverse, range, indexOf, lastIndexOf, join, slice,
            remove, insert, insertAll, partition,
            ap, of, empty, chain, commuteMap, commute, unnest, zipObj, fromPairs, scan,
            createMapEntry, repeat, init, mapAccum, mapAccumRight, mergeAll, aperture, none,
            adjust, update, intersperse, dropRepeats, dropRepeatsWith, lensIndex,
            dropLast, dropLastWhile, takeLast, takeLastWhile, splitEvery, uniqBy
    provides Prelude

  // `_curry3(_reduce)` (`src/reduce.js`), `acc = fn(acc, list[idx])` for idx
  // ascending. v0.10.0 renamed `foldl`, `_curry3(_foldl)` with the same loop,
  // to `reduce`. (`reduce` held the definition from v0.4.0 to v0.8.0, with
  // `foldl` its alias, which held it until v0.3.0; v0.9.0 removed `reduce`
  // and gave `foldl` the code.) Since v0.12.0 `_reduce` speaks the
  // transducer protocol: it stops when the accumulator has a truthy
  // `@@transducer/reduced` property and returns its `@@transducer/value`
  // (`__transducers_reduced__` and `value` until v0.13.0), which a generic A
  // cannot single out (README "Deviations"); it also dispatches to a
  // `reduce` method of a non-list and walks iterators.
  function reduce<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      reduce(fn, acc, list) == fn(reduce(fn, acc, list[..|list| - 1]), list[|list| - 1])
  { if |list| == 0 then acc
    else assert |list| > 1 ==> list[..|list| - 1][1..] == list[1..][..|list| - 2];
         reduce(fn, fn(acc, list[0]), list[1..]) }

  // `var idx = list.length; while (idx--) { acc = fn(acc, list[idx]); }`
  // (`src/reduceRight.js`): `acc = fn(acc, list[idx])` for idx descending.
  // Since v0.1.1 the accumulator comes first, as in reduce, and the fold runs
  // from the right, so reduceRight(fn, acc, [x0, ..., xn]) is
  // fn(... fn(fn(acc, xn), xn-1) ..., x0). v0.10.0 renamed `foldr` to
  // `reduceRight` with the same code. (`reduceRight` held the definition
  // from v0.4.1 to v0.8.0, with `foldr` its alias; v0.9.0 removed it and gave
  // `foldr` the code, which no longer dispatches to a `reduceRight` method.)
  function reduceRight<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      reduceRight(fn, acc, list) == reduceRight(fn, fn(acc, list[|list| - 1]), list[..|list| - 1])
  { if |list| == 0 then acc
    else assert |list| > 1 ==> list[..|list| - 1][1..] == list[1..][..|list| - 2];
         fn(reduceRight(fn, acc, list[1..]), list[0]) }

  // `R.scan(fn, acc, list)` (v0.10.0, which renamed `scanl`, added in
  // v0.7.0, with the same code): `result[0] = acc; while (++idx < len) { acc
  // = fn(acc, list[idx - 1]); result[idx] = acc; }`, the accumulator followed
  // by each successive `fn(acc, x)` (fn gets exactly those two).
  function scan<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): seq<A>
    ensures |scan(fn, acc, list)| == |list| + 1
    ensures scan(fn, acc, list)[0] == acc
  { [acc] + (if |list| == 0 then [] else scan(fn, fn(acc, list[0]), list[1..])) }

  // `R.unfold(fn, seed)` (v0.10.0, which renamed `unfoldr` with the same
  // code): JS loops until `fn` returns a falsy value (None here), possibly
  // forever; Dafny functions must terminate, so at most `fuel` elements are
  // produced.
  function unfold<S, T>(fn: S -> Option<(T, S)>, seed: S, fuel: nat): seq<T>
    decreases fuel
    ensures |unfold(fn, seed, fuel)| <= fuel
  { if fuel == 0 then []
    else match fn(seed)
      case None => []
      case Some(pair) => [pair.0] + unfold(fn, pair.1, fuel - 1) }

  // `map` is a Dafny keyword, so Ramda's `map` is named mapSeq.
  function mapSeq<A, B>(fn: A -> B, list: seq<A>): seq<B>
    ensures |mapSeq(fn, list)| == |list|
    ensures forall i :: 0 <= i < |list| ==> mapSeq(fn, list)[i] == fn(list[i])
  { seq(|list|, i requires 0 <= i < |list| => fn(list[i])) }

  // `_reduce(function(acc, key) { acc[key] = fn(obj[key]); return acc; }, {}, keys(obj))`
  // (`foldl` until v0.8.0 and `_foldl` in v0.9.x, the same function):
  // fn applied to every own property. (In JS an own `__proto__` property is
  // dropped, as the assignment sets the prototype, and since v0.12.0 a
  // truthy `@@transducer/reduced` result (`__transducers_reduced__` until
  // v0.13.0) ends the fold; README "Deviations".)
  function mapObj<V, W>(fn: V -> W, obj: map<string, V>): map<string, W>
    ensures mapObj(fn, obj).Keys == obj.Keys
    ensures forall k :: k in obj ==> mapObj(fn, obj)[k] == fn(obj[k])
  { map k | k in obj :: fn(obj[k]) }

  // `R.mapObjIndexed` (v0.9.0, which renamed `mapObj.idx`, added in v0.2.2,
  // with the same code): `fn(obj[key], key, obj)` for every own property
  // (an own `__proto__` dropped in JS, and `@@transducer/reduced` ending the
  // fold since v0.12.0, as for mapObj). Since v0.14.0 its JSDoc says
  // `@category Object`; functions do not move between modules.
  function mapObjIndexed<V, W>(fn: (V, string, map<string, V>) -> W, obj: map<string, V>): map<string, W>
    ensures mapObjIndexed(fn, obj).Keys == obj.Keys
    ensures forall k :: k in obj ==> mapObjIndexed(fn, obj)[k] == fn(obj[k], k, obj)
  { map k | k in obj :: fn(obj[k], k, obj) }

  // `R.ap(fns, vs)` (v0.3.0): `foldl(function(acc, fn) { return concat(acc,
  // map(fn, vs)); }, [], fns)` (since v0.9.0 `_ap`, with `_foldl`, which
  // v0.10.0 renamed `_reduce`, as `foldl` became `reduce`), every
  // function applied to every value, the functions outermost
  // (`ap([f, g], [1, 2])` is `[f(1), f(2), g(1), g(2)]`). A non-array object with an `ap` method is dispatched to (Fantasy-land;
  // since v0.5.0 the first argument, `fns.ap(vs)`, before that `vs`); no
  // Dafny value has one.
  function ap<A, B>(fns: seq<A -> B>, vs: seq<A>): seq<B>
  { reduce((acc: seq<B>, fn: A -> B) => acc + mapSeq(fn, vs), [], fns) }

  // `function of(x) { return [x]; }` (v0.10.0, "remove dispatch from
  // R.of"): the singleton list. From v0.3.0 to v0.9.1 `R.of(x, container)`
  // called `container.of(x)` for a container with an `of` method
  // (Fantasy-land) and ignored any other container, a parameter the port
  // never had.
  function of<T>(x: T): seq<T> { [x] }

  // `R.empty(x)` (v0.3.0): `[]`, unless x has an `empty` method, which is
  // then called (Fantasy-land). Since v0.16.0 ("define R.empty for Object
  // and String") it also calls `x.constructor.empty()`, and otherwise gives
  // `[]` for an array, `{}` for an object, '' for a string and undefined for
  // anything else (`empty(5)` was `[]`). Here x is a list (a Dafny string
  // too, whose empty value is ""), whose element type the result shares
  // (README "Deviations").
  function empty<T>(x: seq<T>): seq<T> { [] }

  // `R.chain(f, list)` (v0.3.0): `unnest(map(f, list))`, f mapped over the
  // list and its results concatenated, one level deep. A non-array list with
  // a `chain` method is dispatched to. f returns a list here; JS keeps a
  // result that is not array-like (a number, a string) as one element
  // (README "Deviations"). The body concatenates the mapped lists (with
  // `reduce`, `foldl` until v0.9.1). (Since v0.15.0 it is
  // `_dispatchable('chain', _xchain, _chain)` with `_chain = unnest(map(f,
  // list))`, the exported `map`: a transformer makes it a transducer.)
  function chain<A, B>(f: A -> seq<B>, list: seq<A>): seq<B>
  { reduce((acc: seq<B>, xs: seq<B>) => acc + xs, [], mapSeq(f, list)) }

  // `R.commuteMap(fn, of, list)` (v0.8.0): `_reduce(consF, of([]), list)`
  // with `consF(acc, ftor) = _ap(_map(append, fn(ftor)), acc)` (v0.10.0;
  // v0.9.x folded with `_foldl`, which v0.10.0 renamed `_reduce`, and the
  // body with `foldl`; v0.8.0 folded with `reduce`, which v0.9.0 removed, and
  // called `R.ap` and `R.map`), which turns a
  // list of functors into a functor of lists, fn transforming each functor
  // first. For arrays: every way of picking one element of fn(ftor) for each
  // ftor, the first list's element varying fastest (`commuteMap(map(x => x +
  // 10), of, [[1, 2], [3]])` is `[[11, 13], [12, 13]]`). JS dispatches `ap`
  // and `map` to any Fantasy-land functor, with of building the result's
  // functor (since v0.9.0 only `of`'s functor and its `ap`); here they are
  // arrays (README "Deviations"). `R.append` (Core) is written out as
  // `l + [x]`.
  function commuteMap<A, B>(fn: seq<A> -> seq<B>, of: seq<B> -> seq<seq<B>>, list: seq<seq<A>>): seq<seq<B>>
  { reduce((acc: seq<seq<B>>, ftor: seq<A>) => ap(mapSeq((x: B) => ((l: seq<B>) => l + [x]), fn(ftor)), acc),
           of([]), list) }

  // `R.commute = commuteMap(identity)` (v0.16.0, "Make `commute` more
  // efficient"; `commuteMap(map(identity))` from v0.8.0 to v0.15.1, the same
  // results on arrays): commuteMap with no transformation (`commute(of, [[1,
  // 2], [3, 4]])` is `[[1, 3], [2, 3], [1, 4], [2, 4]]`). `R.identity` (Core)
  // is written out as `xs => xs`.
  function commute<A>(of: seq<A> -> seq<seq<A>>, list: seq<seq<A>>): seq<seq<A>>
  { commuteMap((xs: seq<A>) => xs, of, list) }

  function filter<T>(fn: T -> bool, list: seq<T>): seq<T>
    ensures |filter(fn, list)| <= |list|
    ensures forall i :: 0 <= i < |filter(fn, list)| ==> fn(filter(fn, list)[i])
    ensures forall i :: 0 <= i < |filter(fn, list)| ==> filter(fn, list)[i] in list
    ensures forall i :: 0 <= i < |list| && fn(list[i]) ==> list[i] in filter(fn, list)
    ensures multiset(filter(fn, list)) <= multiset(list)
  { if |list| == 0 then []
    else assert list == [list[0]] + list[1..];
         if fn(list[0]) then [list[0]] + filter(fn, list[1..]) else filter(fn, list[1..]) }

  // `filter(not(fn), list)` (since v0.10.0 the exported `filter`, which
  // dispatches to a `filter` method of a non-array object; v0.9.x called the
  // private `_filter`; the same on lists)
  function reject<T>(fn: T -> bool, list: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |reject(fn, list)| ==> !fn(reject(fn, list)[i])
    ensures forall i :: 0 <= i < |reject(fn, list)| ==> reject(fn, list)[i] in list
    ensures forall i :: 0 <= i < |list| && !fn(list[i]) ==> list[i] in reject(fn, list)
  { filter(x => !fn(x), list) }

  // `while (++idx < len && fn(list[idx])) {}; return _slice(list, 0, idx);`:
  // the longest prefix whose elements all satisfy fn. (From v0.2.0 to v0.2.3
  // `_slice` read an end index of 0 as "the end", so when the first element
  // failed fn the whole list came back; v0.2.4 fixed `_slice`.) The body
  // finds the first failing index with findIndex (-1 when every element
  // passes).
  function takeWhile<T>(fn: T -> bool, list: seq<T>): seq<T>
    ensures takeWhile(fn, list) <= list
    ensures forall i :: 0 <= i < |takeWhile(fn, list)| ==> fn(list[i])
    ensures |takeWhile(fn, list)| < |list| ==> !fn(list[|takeWhile(fn, list)|])
  { var i := findIndex(x => !fn(x), list);
    if i == -1 then list else list[..i] }

  // `slice(0, n < 0 ? Infinity : n, xs)` (v0.15.0, the exported `slice`,
  // which dispatches to the target's own `slice`): the first n elements, or
  // the whole list, which a negative n now gives too (`take(-1, [1, 2, 3])`
  // is `[1, 2, 3]`; Infinity is the end, clamped to the length). From v0.3.0
  // to v0.14.0 it was `_slice(list, 0, …)` (v0.1.5 set a copy's length to
  // `Math.min(n, list.length)`; before, `take(5, [1, 2])` had three
  // undefined slots), and from v0.8.0, where `_slice` allocates
  // `Math.max(0, to - from)` elements, a negative n gave []; until v0.7.2 it
  // threw RangeError, and n was a nat.
  function take<T>(n: int, list: seq<T>): seq<T>
    ensures |take(n, list)| == if n < 0 || n > |list| then |list| else n
    ensures take(n, list) <= list
  { slice(0, if n < 0 then |list| else n, list) }

  // `R.dropWhile(pred, list)` (v0.9.0, in place of `skipUntil`, which
  // skipped until the predicate held): `while (++idx < len &&
  // pred(list[idx])) {}; return _slice(list, idx);`, the suffix starting at
  // the first element that fails pred (`dropWhile(p, l)` is v0.8.0's
  // `skipUntil(x => !p(x), l)`).
  function dropWhile<T>(pred: T -> bool, list: seq<T>): seq<T>
    ensures |dropWhile(pred, list)| <= |list|
    ensures dropWhile(pred, list) == list[|list| - |dropWhile(pred, list)|..]
    ensures forall i :: 0 <= i < |list| - |dropWhile(pred, list)| ==> pred(list[i])
    ensures |dropWhile(pred, list)| > 0 ==> !pred(dropWhile(pred, list)[0])
  { if |list| == 0 || !pred(list[0]) then list else dropWhile(pred, list[1..]) }

  // `R.drop` (v0.9.0, which renamed `skip` with the same code; it dispatches
  // to a `drop` method of a non-array where `skip` called `skip`):
  // `slice(Math.max(0, n), Infinity, xs)` (v0.15.0, the exported `slice`,
  // Infinity being the end; v0.14.0's `n <= 0 ? list : _slice(list, n)`, the
  // same results, "treat negative number as zero"): all but the first n
  // elements, the whole list for n <= 0, or [] when n is at least the length.
  // From v0.5.0 ("Fix a bug in R.skip") to v0.13.0 the body was
  // `n < list.length ? _slice(list, n) : []`, so a negative n read undefined
  // holes before the start (`drop(-1, [1, 2])` was `[undefined, 1, 2]`) and
  // n was a nat. From v0.2.0 to v0.4.3 `_slice` allocated
  // `new Array(list.length - n)`, which threw RangeError for n > |list|
  // (`skip(5, [1, 2])`), so n was at most |list|; before v0.2.0 it was [].
  function drop<T>(n: int, list: seq<T>): seq<T>
    ensures 0 <= n <= |list| ==> drop(n, list) == list[n..]
    ensures n >= |list| ==> drop(n, list) == []
    ensures n <= 0 ==> drop(n, list) == list
  { slice(if n < 0 then 0 else n, |list|, list) }

  // The first element satisfying fn; JS returns undefined when none does.
  function find<T>(fn: T -> bool, list: seq<T>): Option<T>
    ensures find(fn, list) == (if |filter(fn, list)| == 0 then None else Some(filter(fn, list)[0]))
  { if |list| == 0 then None
    else if fn(list[0]) then Some(list[0])
    else find(fn, list[1..]) }

  // The index of the first element satisfying fn, or -1 when none does
  // (v0.2.0; it was undefined, here None, before).
  function findIndex<T>(fn: T -> bool, list: seq<T>): int
    ensures -1 <= findIndex(fn, list) < |list|
    ensures findIndex(fn, list) >= 0 ==>
      fn(list[findIndex(fn, list)]) && forall j :: 0 <= j < findIndex(fn, list) ==> !fn(list[j])
    ensures findIndex(fn, list) == -1 <==> forall j :: 0 <= j < |list| ==> !fn(list[j])
  { if |list| == 0 then -1
    else if fn(list[0]) then 0
    else var r := findIndex(fn, list[1..]);
         if r == -1 then -1 else r + 1 }

  // `var idx = list.length; while (idx--) { if (fn(list[idx])) return list[idx]; }`
  // (v0.4.2): the last element satisfying fn, or undefined (None) when none
  // does. Until v0.4.1 the loop was `while (--idx)`, which never tested index
  // 0 (`findLast(fn, [x])` was undefined even when fn(x) held) and on the
  // empty list ran idx through -1, -2, ... calling fn(undefined) until it was
  // truthy, so the empty list was excluded.
  function findLast<T>(fn: T -> bool, list: seq<T>): Option<T>
    ensures findLast(fn, list).Some? ==>
      exists i :: 0 <= i < |list| && list[i] == findLast(fn, list).value && fn(list[i]) &&
                  forall j :: i < j < |list| ==> !fn(list[j])
    ensures findLast(fn, list).None? <==> forall j :: 0 <= j < |list| ==> !fn(list[j])
  { if |list| == 0 then None
    else if fn(list[|list| - 1]) then Some(list[|list| - 1])
    else var r := findLast(fn, list[..|list| - 1]);
         assert forall j :: 0 <= j < |list| - 1 ==> list[..|list| - 1][j] == list[j];
         r }

  // As findLast, returning the index, or -1 when no element satisfies fn
  // (v0.2.0; it was undefined, here None, before). Since v0.4.2 index 0 is
  // tested and the empty list gives -1 (until v0.4.1 neither held, and the
  // empty list was excluded).
  function findLastIndex<T>(fn: T -> bool, list: seq<T>): int
    ensures -1 <= findLastIndex(fn, list) < |list|
    ensures findLastIndex(fn, list) >= 0 ==>
      fn(list[findLastIndex(fn, list)]) &&
      forall j :: findLastIndex(fn, list) < j < |list| ==> !fn(list[j])
    ensures findLastIndex(fn, list) == -1 <==> forall j :: 0 <= j < |list| ==> !fn(list[j])
  { if |list| == 0 then -1
    else if fn(list[|list| - 1]) then |list| - 1
    else var r := findLastIndex(fn, list[..|list| - 1]);
         assert forall j :: 0 <= j < |list| - 1 ==> list[..|list| - 1][j] == list[j];
         r }

  // `R.all = _curry2(_all)` (v0.9.0, which renamed `every` with the same
  // code; v0.4.1 had renamed `all` to `every`): fn holds for every element.
  function all<T>(fn: T -> bool, list: seq<T>): bool
  { forall i :: 0 <= i < |list| ==> fn(list[i]) }

  // `R.any = _curry2(_any)` (v0.9.0, `some` renamed likewise): fn holds for
  // some element.
  function any<T>(fn: T -> bool, list: seq<T>): bool
  { exists i :: 0 <= i < |list| && fn(list[i]) }

  // `_indexOf(list, a) >= 0` (`===` until v0.13.0, `_eq`, `Object.is`, in
  // v0.14.0, and since v0.15.0 `R.equals`, deep equality, which on Dafny
  // values is `==`; see README on `-0`; `op`-curried from v0.9.0 to v0.10.0 and `_curry2` since v0.11.0,
  // which only add the placeholder form `contains(__, list)`).
  function contains<T(==)>(a: T, list: seq<T>): bool { a in list }

  // `pred(x, list[idx])` for some idx (exported since v0.1.5).
  function containsWith<T>(pred: (T, T) -> bool, x: T, list: seq<T>): bool
  { exists i :: 0 <= i < |list| && pred(x, list[i]) }

  // `var result = []; ... if (!contains(item, result)) result.push(item);`
  // for each item in order (v0.2.4; until v0.2.3 a foldr from the right kept
  // the LAST occurrences): each element at its FIRST occurrence, in list
  // order (`uniq([1, 2, 1, 3, 2]) == [1, 2, 3]`). The body recurses on all
  // but the last element and then decides the last one, which is the loop.
  // In v0.14.0 `R.uniq = uniqWith(eq)`, the same loop with `Object.is`, and
  // since v0.15.1 `uniqWith(equals)`, with deep equality (4b417682 reverted
  // v0.15.0's loop, which kept a JS `Set` of the items, comparing by
  // `SameValueZero`, objects by reference, except that `0`, `-0` and an
  // object with an `equals` method were looked up with `R.equals`); the
  // results on Dafny values are the same (README "Deviations" on `-0`), and
  // the body keeps its own recursion, as `head` and `last` did when v0.8.0
  // wrote them on `nth`.
  function {:isolate_assertions} uniq<T(==)>(list: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |uniq(list)| ==> uniq(list)[i] in list
    ensures forall i :: 0 <= i < |list| ==> list[i] in uniq(list)
    ensures forall i, j :: 0 <= i < j < |uniq(list)| ==> uniq(list)[i] != uniq(list)[j]
    ensures forall i, j :: 0 <= i < j < |uniq(list)| ==>
      indexOf(uniq(list)[i], list) < indexOf(uniq(list)[j], list)
    ensures |list| > 0 ==>
      uniq(list) ==
        (if list[|list| - 1] in uniq(list[..|list| - 1]) then uniq(list[..|list| - 1])
         else uniq(list[..|list| - 1]) + [list[|list| - 1]])
  { if |list| == 0 then []
    else var init := list[..|list| - 1];
         var x := list[|list| - 1];
         var acc := uniq(init);
         assert forall k :: 0 <= k < |acc| ==> acc[k] in init;
         assert forall k :: 0 <= k < |init| ==> init[k] == list[k];
         assert forall y :: y in init ==> indexOf(y, list) == indexOf(y, init) by {
           forall y | y in init ensures indexOf(y, list) == indexOf(y, init) {
             var p := indexOf(y, init);
             var q := indexOf(y, list);
             assert 0 <= p < |init| && init[p] == y;
             assert list[p] == y;
             assert q != -1;
             if q < p { assert init[q] == y; }
           }
         }
         assert forall k :: 0 <= k < |init| ==> init[k] in acc;
         if x in acc then
           assert forall i :: 0 <= i < |list| ==> list[i] in acc by {
             forall i | 0 <= i < |list| ensures list[i] in acc {
               if i < |list| - 1 { assert list[i] == init[i]; }
             }
           }
           acc
         else
           var r := acc + [x];
           assert forall i :: 0 <= i < |list| ==> list[i] in r by {
             forall i | 0 <= i < |list| ensures list[i] in r {
               if i < |list| - 1 { assert list[i] == init[i]; assert init[i] in acc; }
             }
           }
           assert x !in init by {
             if x in init {
               var k :| 0 <= k < |init| && init[k] == x;
               assert init[k] in acc;
             }
           }
           assert indexOf(x, list) == |list| - 1 by {
             var q := indexOf(x, list);
             if 0 <= q < |list| - 1 { assert init[q] == x; }
           }
           assert forall i, j :: 0 <= i < j < |r| ==> indexOf(r[i], list) < indexOf(r[j], list) by {
             forall i, j | 0 <= i < j < |r| ensures indexOf(r[i], list) < indexOf(r[j], list) {
               assert r[i] == acc[i];
               assert acc[i] in init;
               if j < |acc| { assert r[j] == acc[j]; }
             }
           }
           r }

  // True exactly when no element occurs twice, which is the body. (v0.2.4
  // checks `indexOf(list, list[i], i + 1) < 0` for every i, since v0.14.0
  // with `Object.is` and since v0.15.0 with `R.equals`; until v0.2.3 it was `uniq(list).length ===
  // list.length`, the same result.)
  function isSet<T(==)>(list: seq<T>): bool
  { forall i, j :: 0 <= i < j < |list| ==> list[i] != list[j] }

  // `var result = []; ... if (!containsWith(pred, item, result)) result.push(item);`
  // for each item in order (v0.2.4; exported since v0.2.0, and until v0.2.3
  // a foldr from the right that kept the LAST representative): item is kept
  // when `pred(item, r)` fails for every r already kept, so each class keeps
  // its FIRST representative (`uniqWith((a, b) => a % 3 == b % 3, [1, 2, 3, 4])`
  // is `[1, 2, 3]`). The body recurses on all but the last element.
  function uniqWith<T>(pred: (T, T) -> bool, list: seq<T>): seq<T>
    ensures |list| == 0 ==> uniqWith(pred, list) == []
    ensures |list| > 0 ==>
      uniqWith(pred, list) ==
        (if containsWith(pred, list[|list| - 1], uniqWith(pred, list[..|list| - 1]))
         then uniqWith(pred, list[..|list| - 1])
         else uniqWith(pred, list[..|list| - 1]) + [list[|list| - 1]])
    ensures forall i :: 0 <= i < |uniqWith(pred, list)| ==> uniqWith(pred, list)[i] in list
    ensures forall i, j :: 0 <= i < j < |uniqWith(pred, list)| ==>
      !pred(uniqWith(pred, list)[j], uniqWith(pred, list)[i])
    ensures forall x | x in list ::
      x in uniqWith(pred, list) ||
      exists j :: 0 <= j < |uniqWith(pred, list)| && pred(x, uniqWith(pred, list)[j])
  { if |list| == 0 then []
    else var init := list[..|list| - 1];
         var x := list[|list| - 1];
         var acc := uniqWith(pred, init);
         assert forall y | y in list :: y == x || y in init;
         if containsWith(pred, x, acc) then acc
         else var r := acc + [x];
              assert forall j :: 0 <= j < |acc| ==> r[j] == acc[j];
              assert forall y | y in acc :: y in r;
              r }

  // `map(prop(p), list)` (since v0.14.0 the exported, dispatching `map`; the
  // private `_map` before, the same on lists): a missing property is JS
  // undefined, here None. (In JS a name of an `Object.prototype` member that
  // an object lacks gives the inherited member, as for `prop`: README
  // "Deviations".)
  function pluck<V>(p: string, list: seq<map<string, V>>): seq<Option<V>>
    ensures |pluck(p, list)| == |list|
  { mapSeq((obj: map<string, V>) => if p in obj then Some(obj[p]) else None, list) }

  // Depth-first, left-to-right concatenation of the leaves. (v0.3.0's
  // `makeFlat(true)` flattens every array-like element, an object with a
  // numeric `length` included, where the loop before it flattened arrays
  // only; v0.4.0's `isArrayLike` no longer counts a function, whose `length`
  // is its arity, but adds an object with `nodeType === 1` and a truthy
  // `length`, and v0.7.2's counts an object with a positive `length` only
  // when it owns the indices 0 and `length - 1`. A Leaf is never flattened,
  // README "Deviations".)
  function flatten<T>(list: seq<Tree<T>>): seq<T>
  { if |list| == 0 then []
    else (match list[0] case Leaf(v) => [v] case Node(c) => flatten(c)) + flatten(list[1..]) }

  // `makeFlat(false)` (v0.3.0): one level of nesting removed, a Node's
  // children spliced in and a Leaf kept (`unnest([1, [2], [[3]]])` is
  // `[1, 2, [3]]`).
  function unnest<T>(list: seq<Tree<T>>): seq<Tree<T>>
  { if |list| == 0 then []
    else (match list[0] case Leaf(_) => [list[0]] case Node(c) => c) + unnest(list[1..]) }

  // `rv[i] = fn(a[i], b[i])` for i below `Math.min(a.length, b.length)`
  // (v0.2.0; before, i ran to a.length and read `undefined` past the end of
  // b, so b had to be at least as long as a).
  function zipWith<A, B, C>(fn: (A, B) -> C, a: seq<A>, b: seq<B>): seq<C>
    ensures |zipWith(fn, a, b)| == if |a| <= |b| then |a| else |b|
    ensures forall i :: 0 <= i < |zipWith(fn, a, b)| ==> zipWith(fn, a, b)[i] == fn(a[i], b[i])
  { var n := if |a| <= |b| then |a| else |b|;
    seq(n, i requires 0 <= i < n => fn(a[i], b[i])) }

  function zip<A, B>(a: seq<A>, b: seq<B>): seq<(A, B)>
    ensures |zip(a, b)| == if |a| <= |b| then |a| else |b|
    ensures forall i :: 0 <= i < |zip(a, b)| ==> zip(a, b)[i] == (a[i], b[i])
  { var n := if |a| <= |b| then |a| else |b|;
    seq(n, i requires 0 <= i < n => (a[i], b[i])) }

  // `R.zipObj(keys, values)` (v0.3.0): `out[keys[i]] = values[i]` for i
  // ascending, so a later duplicate key wins and extra values are ignored.
  // An extra key gets an undefined value, which is still an own property
  // (`zipObj(['a', 'b'], [1])` has the keys a and b), so keys may not
  // outnumber values. JS converts keys to strings, and a key such as
  // `__proto__` is not an ordinary property (README "Deviations"). The body
  // sets the last key on the object built from the others, which is the loop.
  function zipObj<V>(keys: seq<string>, values: seq<V>): map<string, V>
    requires |keys| <= |values|
  { if |keys| == 0 then map[]
    else zipObj(keys[..|keys| - 1], values)[keys[|keys| - 1] := values[|keys| - 1]] }

  // `R.fromPairs(pairs)` (v0.3.0): `out[pairs[i][0]] = pairs[i][1]` for each
  // element that is a non-empty array, i ascending, so a later duplicate key
  // wins. The pairs are typed here, so the elements JS skips (non-arrays,
  // empty arrays) and one-element arrays (an undefined value) cannot be
  // written (README "Outside the modeled domain"); a key such as `__proto__`
  // is not an ordinary property in JS (README "Deviations").
  function fromPairs<V>(pairs: seq<(string, V)>): map<string, V>
  { if |pairs| == 0 then map[]
    else fromPairs(pairs[..|pairs| - 1])[pairs[|pairs| - 1].0 := pairs[|pairs| - 1].1] }

  // `R.createMapEntry(key, val)` (v0.7.0): `var obj = {}; obj[key] = val;
  // return obj;`, the object with the one property. Defined in "List
  // Functions", hence here. JS converts the key to a string, and a
  // `__proto__` key sets the prototype instead of a property (README
  // "Deviations").
  function createMapEntry<V>(key: string, val: V): map<string, V> { map[key := val] }

  // `R.lens(getter, setter)` (v0.8.0; defined in "List Functions", hence
  // here, though since v0.16.0 its JSDoc says `@category Object`): since
  // v0.16.0 ("composable lenses", 2d0b0270) `function(f) { return
  // function(s) { return map(function(v) { return setter(v, s); },
  // f(getter(s))); }; }`, a van Laarhoven lens (`Prelude.Lens`): given a
  // function from the focus to a functor, a function from the whole to that
  // functor, which `view`, `set_` and `over` (Object.dfy) run and `compose`
  // composes. `R.map` on the functor is `Prelude.map_`, written out as its
  // match: Dafny does not unfold a function called inside the returned
  // lambda when a caller applies the lambda (only its requires), and `view`
  // and `over` need the result's constructor. The getter and setter are
  // partial arrows: the lens requires the getter's precondition, f's on the
  // focus and, for an `Identity`, the setter's on the new focus. (From v0.8.0
  // to v0.15.1 `lens(get, set)` returned `lns(a) = get(a)` with the
  // properties `lns.set = set` and `lns.map = (fn, a) => set(fn(get(a)),
  // a)`, the record `Prelude.Lens(get, set_, map_)` here; in v0.16.0
  // `lens(g, s)(a)` is a function, and `.set` and `.map` are undefined.)
  function lens<S, V, X>(getter: S --> V, setter: (V, S) --> S): Lens<S, V, X>
  { (f: V --> Functor<X, V>) =>
      (s: S) requires getter.requires(s) && f.requires(getter(s)) &&
                      (f(getter(s)).Identity? ==> setter.requires(f(getter(s)).v, s)) =>
        match f(getter(s))
          case Const(c) => Const(c)
          case Identity(v) => Identity(setter(v, s)) }

  // Every pair `[a[idx], b[j]]`, the first list's index outermost: Ramda's
  // nested loops (`[]` when either list is empty). Until v0.7.2 the body was
  // `xprodWith` of the pairing function, which v0.8.0 removed (Ramda's own
  // `xprod` always had its own loops), with the same results. (v0.9.0 drops
  // Ramda's `isEmpty` guard, which the loops make redundant.)
  function xprod<A, B>(a: seq<A>, b: seq<B>): seq<(A, B)>
    ensures |xprod(a, b)| == |a| * |b|
  { if |a| == 0 || |b| == 0 then []
    else mapSeq((y: B) => (a[0], y), b) + xprod(a[1..], b) }

  // `_slice(list).reverse()` (v0.9.0; an explicit loop since v0.6.0): the
  // list back to front.
  function reverse<T>(list: seq<T>): seq<T>
    ensures |reverse(list)| == |list|
    ensures forall i :: 0 <= i < |list| ==> reverse(list)[i] == list[|list| - 1 - i]
  { seq(|list|, i requires 0 <= i < |list| => list[|list| - 1 - i]) }

  // from (inclusive) to to (exclusive); empty when from >= to.
  function range(from: int, to: int): seq<int>
    ensures |range(from, to)| == if from >= to then 0 else to - from
    ensures forall i :: 0 <= i < |range(from, to)| ==> range(from, to)[i] == from + i
  { if from >= to then [] else seq(to - from, i => from + i) }

  // `_indexOf(list, obj)`: the first index of obj, or -1 (`===`, in v0.14.0
  // `Object.is`, since v0.15.0 `R.equals`: README "Deviations" on `-0`;
  // since v0.15.0 a non-array with an `indexOf` method is dispatched to).
  function indexOf<T(==)>(obj: T, list: seq<T>): int
    ensures -1 <= indexOf(obj, list) < |list|
    ensures indexOf(obj, list) == -1 <==> obj !in list
    ensures indexOf(obj, list) >= 0 ==>
      indexOf(obj, list) < |list| && list[indexOf(obj, list)] == obj &&
      forall i :: 0 <= i < indexOf(obj, list) ==> list[i] != obj
  { if |list| == 0 then -1
    else if list[0] == obj then 0
    else var r := indexOf(obj, list[1..]);
         if r < 0 then -1 else r + 1 }

  // `_lastIndexOf(list, obj)`: the last index of obj, or -1 (`===`, in
  // v0.14.0 `Object.is`, since v0.15.0 `R.equals`, and a non-array's own
  // `lastIndexOf` is dispatched to).
  function lastIndexOf<T(==)>(obj: T, list: seq<T>): int
    ensures -1 <= lastIndexOf(obj, list) < |list|
    ensures lastIndexOf(obj, list) == -1 <==> obj !in list
    ensures lastIndexOf(obj, list) >= 0 ==>
      lastIndexOf(obj, list) < |list| && list[lastIndexOf(obj, list)] == obj &&
      forall i :: lastIndexOf(obj, list) < i < |list| ==> list[i] != obj
  { if |list| == 0 then -1
    else if list[|list| - 1] == obj then |list| - 1
    else lastIndexOf(obj, list[..|list| - 1]) }

  // `list.join(sep)` (since v0.8.0 `invokerN(1, 'join')`, since v0.9.0
  // `invoker(1, 'join')`, the target's own method); the elements are strings (see README on numbers).
  function join(sep: string, list: seq<string>): string
  { if |list| == 0 then ""
    else if |list| == 1 then list[0]
    else list[0] + sep + join(sep, list[1..]) }

  // `Array.prototype.slice(from, to)` (an invoker since v0.1.4; since v0.6.0
  // `invoker(Array.prototype.slice)`, which also works on a JS string; since
  // v0.8.0 `invokerN(2, 'slice')`, v0.9.0 `invoker`, the target's own method, so
  // `slice(1, 2, "abc")` is the string "b" where it was ["b"]; both are the
  // Dafny "b"; since v0.11.0 `_checkForMethod('slice', …)` over
  // `Array.prototype.slice.call(xs, from, to)`, which also takes an
  // `arguments` object and still calls a non-array's own `slice`): a negative
  // index counts from the end, both are clamped into the list, and the result
  // is empty when `to` falls at or before `from`.
  function slice<T>(from: int, to: int, list: seq<T>): seq<T>
    ensures var n := |list|;
      var a := if from < 0 then (if n + from < 0 then 0 else n + from) else if from > n then n else from;
      var b := if to < 0 then (if n + to < 0 then 0 else n + to) else if to > n then n else to;
      slice(from, to, list) == if a < b then list[a..b] else []
  { var n := |list|;
    var a := if from < 0 then (if n + from < 0 then 0 else n + from) else if from > n then n else from;
    var b := if to < 0 then (if n + to < 0 then 0 else n + to) else if to > n then n else to;
    if a < b then list[a..b] else [] }

  // `remove`, `insert` and `insert.all` (v0.2.2; `insertAll` since v0.9.0)
  // are built on
  // `_slice(args, from, to)`, which copies args[from..to) into a new array:
  // indices past an end read undefined holes, and until v0.7.2 a negative
  // length (`new Array(to - from)`) threw RangeError; since v0.8.0 the
  // length is `Math.max(0, to - from)`, so nothing is copied. From v0.2.2 to
  // v0.2.3 `_slice` read an end index of 0 as "the end" (`to ||
  // args.length`), so a cut at 0 copied the whole list; v0.2.4 checks
  // `typeof to === "number"` instead.

  // `concat(_slice(list, 0, Math.min(start, length)), _slice(list,
  // Math.min(length, start + count)))`: the list without `count` elements
  // from `start` (`remove(0, 2, [1, 2, 3, 4, 5])` is `[3, 4, 5]`; it was
  // `[1, 2, 3, 4, 5, 3, 4, 5]` before v0.2.4). Since v0.8.0 a negative start
  // makes the first cut empty (`remove(-1, 2, [1, 2, 3, 4, 5])` is
  // `[2, 3, 4, 5]`; until v0.7.2 it threw RangeError, and start was at least
  // 0). start + count < 0 still reads undefined holes, so it is excluded.
  function remove<T>(start: int, count: int, list: seq<T>): seq<T>
    requires 0 <= start + count
    ensures var a := if start < 0 then 0 else if start < |list| then start else |list|;
      var b := if start + count < |list| then start + count else |list|;
      remove(start, count, list) == list[..a] + list[b..]
  { var a := if start < 0 then 0 else if start < |list| then start else |list|;
    var b := if start + count < |list| then start + count else |list|;
    list[..a] + list[b..] }

  // `index` is used when `0 <= index < length` and is `length` (the end)
  // otherwise; then `concat(append(elt, _slice(list, 0, index)),
  // _slice(list, index))`: `insert(0, 9, [1, 2, 3])` is `[9, 1, 2, 3]` (it
  // was `[1, 2, 3, 9, 1, 2, 3]` before v0.2.4). Since v0.16.0 it copies the
  // list and `splice`s elt in at that index, with the same results.
  function insert<T>(index: int, elt: T, list: seq<T>): seq<T>
    ensures var i := if 0 <= index < |list| then index else |list|;
      insert(index, elt, list) == list[..i] + [elt] + list[i..]
  { var i := if 0 <= index < |list| then index else |list|;
    list[..i] + [elt] + list[i..] }

  // `R.insertAll` (`src/insertAll.js`; until v0.8.0 the property
  // `insert.all`, ported under this name): as insert, with the list elts in
  // place of one element: `concat(concat(_slice(list, 0, index), elts),
  // _slice(list, index))`.
  function insertAll<T>(index: int, elts: seq<T>, list: seq<T>): seq<T>
    ensures var i := if 0 <= index < |list| then index else |list|;
      insertAll(index, elts, list) == list[..i] + elts + list[i..]
  { var i := if 0 <= index < |list| then index else |list|;
    list[..i] + elts + list[i..] }

  // `_reduce(function(acc, elt) { acc[pred(elt) ? 0 : 1].push(elt); return acc; }, [[], []], list)`
  // (v0.3.0, "like its Haskell namesake"; `foldl` until v0.8.0, `_foldl` in
  // v0.9.x): the pair of the elements that
  // satisfy pred and those that fail it, each in list order. From v0.1.4 to
  // v0.2.4 partition grouped the elements by the string key fn returned,
  // which groupBy (Data.dfy) now does.
  function partition<T>(pred: T -> bool, list: seq<T>): (seq<T>, seq<T>)
  { (filter(pred, list), reject(pred, list)) }

  // `R.repeat(value, n)` (v0.9.0, which renamed `repeatN` with the same
  // code, `times(always(value), n)`; `@category List` puts it here, where
  // `repeatN` was in Core): n copies of value. Before v0.2.3 the body was
  // `var arr = new Array(n), i = -1; while (++i < n) { arr[i] = value; }`.
  // Since v0.2.0 the array is allocated with `new Array(n)`, which throws
  // RangeError for a negative n (v0.1.3 to v0.1.5 returned []), so n is a
  // nat.
  function repeat<T>(value: T, n: nat): seq<T>
    ensures |repeat(value, n)| == n
    ensures forall i :: 0 <= i < n ==> repeat(value, n)[i] == value
  { seq(n, _ => value) }

  // `R.init = slice(0, -1)` (v0.9.0): all but the last element ([] for []).
  // `slice` is an `invoker`, so on a JS string it gives the string, here the
  // same seq.
  function init<T>(list: seq<T>): seq<T> { slice(0, -1, list) }

  // `R.mapAccum(fn, acc, list)` (v0.10.0, which renamed `mapAccumL`, added
  // in v0.9.0, with the same code): `tuple = [acc]; while (++idx < len) {
  // tuple = fn(tuple[0], list[idx]); result[idx] = tuple[1]; } return
  // [tuple[0], result];`, threading the accumulator left to right through
  // fn, which returns the pair [accumulator, mapped element].
  function mapAccum<A, B, C>(fn: (A, B) -> (A, C), acc: A, list: seq<B>): (A, seq<C>)
    ensures |mapAccum(fn, acc, list).1| == |list|
  { if |list| == 0 then (acc, [])
    else var t := fn(acc, list[0]);
         var r := mapAccum(fn, t.0, list[1..]);
         (r.0, [t.1] + r.1) }

  // `R.mapAccumRight(fn, acc, list)` (v0.10.0, which renamed `mapAccumR`
  // with the same code): as mapAccum with idx descending, `result[idx] =
  // tuple[1]`, so each mapped element stays at its element's index while the
  // accumulator runs right to left.
  function mapAccumRight<A, B, C>(fn: (A, B) -> (A, C), acc: A, list: seq<B>): (A, seq<C>)
    ensures |mapAccumRight(fn, acc, list).1| == |list|
  { if |list| == 0 then (acc, [])
    else var t := fn(acc, list[|list| - 1]);
         var r := mapAccumRight(fn, t.0, list[..|list| - 1]);
         (r.0, r.1 + [t.1]) }

  // `_curry1(function mergeAll(list) { return reduce(merge, {}, list); })`
  // (v0.11.0; v0.10.0's `R.mergeAll = reduce(merge, {})` shared its `{}`
  // accumulator across calls, so `mergeAll([])` was the same object every
  // time), `@category List`: the objects merged left to right, a later
  // object's keys winning. `R.merge` is `Object.merge`, which List does not
  // import, so `merge(acc, obj)` is written out as its body, `acc + obj`. (An
  // own `__proto__` property is dropped in JS, README "Deviations".)
  function mergeAll<V>(list: seq<map<string, V>>): map<string, V>
  { reduce((acc: map<string, V>, obj: map<string, V>) => acc + obj, map[], list) }

  // `R.aperture(n, list)` (v0.12.0, `@category List`): `limit = list.length -
  // (n - 1)`, and for idx below limit `acc[idx] = _slice(list, idx, idx +
  // n)`: every window of n consecutive elements. For n <= 0 the windows are
  // empty and there are `|list| - n + 1` of them (`aperture(0, [1, 2])` is
  // `[[], [], []]`); for n past the length there are none.
  function aperture<T>(n: int, list: seq<T>): seq<seq<T>>
    ensures |aperture(n, list)| == if |list| - (n - 1) >= 0 then |list| - (n - 1) else 0
  { var limit := |list| - (n - 1);
    var count := if limit >= 0 then limit else 0;
    seq(count, idx requires 0 <= idx < count => if n <= 0 then [] else list[idx..idx + n]) }

  // `R.none = _curry2(_complement(_dispatchable('any', _xany, _any)))`
  // (v0.12.0, `@category List`): the negation of `any`, true when no element
  // satisfies fn.
  function none<T>(fn: T -> bool, list: seq<T>): bool { !any(fn, list) }

  // `R.adjust(fn, idx, list)` (v0.14.0, `@category List`): `if (idx >=
  // list.length || idx < -list.length) { return list; }`, and otherwise a
  // copy (`_concat(list)`) with `_list[_idx] = fn(list[_idx])`, where `_idx`
  // is idx plus the length for a negative idx: fn applied to the element at
  // idx, a negative idx counting from the end (`adjust(add(10), -1, [1, 2,
  // 3])` is `[1, 2, 13]`); out of range the list itself. JS lets fn return a
  // value of another type (README "Deviations").
  function adjust<T>(fn: T -> T, idx: int, list: seq<T>): seq<T>
    ensures |adjust(fn, idx, list)| == |list|
  { if idx >= |list| || idx < -|list| then list
    else var i := (if idx < 0 then |list| else 0) + idx;
         list[i := fn(list[i])] }

  // `R.update(idx, x, list)` (v0.14.0): `adjust(always(x), idx, list)`, the
  // element at idx replaced by x (out of range, the list itself).
  // `R.always` is Functions', which List does not import, so it is written
  // out as `_ => x`. JS lets x be of another type (README "Deviations").
  function update<T>(idx: int, x: T, list: seq<T>): seq<T>
  { adjust((_: T) => x, idx, list) }

  // `R.intersperse(separator, list)` (v0.14.0): pushes each element and,
  // after every element but the last, the separator (`intersperse('n',
  // ['ba', 'a', 'a'])` is `['ba', 'n', 'a', 'n', 'a']`). A non-array with an
  // `intersperse` method is dispatched to; a JS string has none, so its
  // characters are interspersed into an array (`intersperse(',', 'abc')` is
  // `['a', ',', 'b', ',', 'c']`), here the same seq<char>.
  function intersperse<T>(separator: T, list: seq<T>): seq<T>
  { if |list| <= 1 then list else [list[0], separator] + intersperse(separator, list[1..]) }

  // `R.dropRepeatsWith(pred, list)` (v0.14.0): `result[0] = list[0]`, then
  // each later element is pushed unless `pred(last(result), list[idx])`: the
  // first element and every element that pred does not match with the last
  // one kept (`dropRepeatsWith(lt, [1, 3, 2, 5, 4])` is `[1]`). A non-array
  // with a `dropRepeatsWith` method is dispatched to, and a transformer makes
  // it a transducer. `R.last` is Core's, which List does not import, so it
  // is written out as `r[|r| - 1]`. The body recurses on all but the last
  // element, as the loop does.
  function dropRepeatsWith<T>(pred: (T, T) -> bool, list: seq<T>): seq<T>
    ensures |dropRepeatsWith(pred, list)| <= |list|
    ensures |list| > 0 ==> |dropRepeatsWith(pred, list)| > 0
  { if |list| <= 1 then list
    else var r := dropRepeatsWith(pred, list[..|list| - 1]);
         if pred(r[|r| - 1], list[|list| - 1]) then r else r + [list[|list| - 1]] }

  // `R.dropRepeats` (v0.14.0): `dropRepeatsWith(_eq)`, since v0.15.0
  // `dropRepeatsWith(equals)`, consecutive equal elements kept once
  // (`dropRepeats([1, 1, 2, 1, 1])` is `[1, 2, 1]`). `Object.is` and, since
  // v0.15.0, the deep `R.equals` are `==` on Dafny values (README
  // "Deviations" on `-0`).
  function dropRepeats<T(==)>(list: seq<T>): seq<T>
  { dropRepeatsWith((a: T, b: T) => a == b, list) }

  // `R.lensIndex(n)` (v0.14.0, `@category List`; `@category Object` in
  // v0.16.0's JSDoc): since v0.15.1 `_curry1(lens(nth(n), update(n)))`
  // (77d7863a), a lens on the element at n, since v0.16.0 a van Laarhoven
  // lens (see `lens`), so it takes the functor's carried type X. The getter is `nth(n)`, a negative n counting from the end; out of
  // range it is undefined, which no element holds, so it requires the index
  // in the list (`R.nth` is Core's, which List does not import, so it is
  // written out), and so does the lens, which applies its function to the
  // getter's result.
  // The setter is `update(n)`, which replaces the element at n (a negative n
  // counting from the end) and leaves the list as it is out of range
  // (`lensIndex(5).set(9, [1, 2])` and `lensIndex(0).set(9, [])` are `[1,
  // 2]` and `[]`, `lensIndex(-1).set(9, [1, 2])` is `[1, 9]`). In v0.14.0
  // and v0.15.0 the setter was `_slice(xs, 0, n).concat([x], _slice(xs, n +
  // 1))`, which appended for n at or past the end (`[1, 2, 9]`), prepended
  // for n == -1 (`[9, 1, 2]`) and read undefined holes before the start for
  // n <= -2, so it required n >= -1 (README "Outside the modeled domain").
  function lensIndex<T, X>(n: int): Lens<seq<T>, T, X>
  { lens((xs: seq<T>) requires 0 <= (if n < 0 then |xs| + n else n) < |xs| =>
           xs[if n < 0 then |xs| + n else n],
         (x: T, xs: seq<T>) => update(n, x, xs)) }

  // `R.dropLast(n, xs)` (v0.16.0, `@category List`): `take(n < xs.length ?
  // xs.length - n : 0, xs)`, all but the last n elements: the whole list
  // for n <= 0 and [] for n at least the length (`dropLast(1, [1, 2, 3])` is
  // `[1, 2]`); on a JS string `take` gives a string, the same seq here.
  function dropLast<T>(n: int, list: seq<T>): seq<T>
  { take(if n < |list| then |list| - n else 0, list) }

  // `R.dropLastWhile(pred, list)` (v0.16.0): `idx = list.length - 1; while
  // (idx >= 0 && pred(list[idx])) { idx -= 1; } return _slice(list, 0, idx +
  // 1);`, the list without its longest suffix whose elements satisfy pred
  // (`dropLastWhile(x => x > 2, [1, 3, 2, 4, 5])` is `[1, 3, 2]`). On a JS
  // string `_slice` gives an array of characters, the same seq here. The
  // body recurses on all but the last element, as the loop does.
  function dropLastWhile<T>(pred: T -> bool, list: seq<T>): seq<T>
    ensures dropLastWhile(pred, list) <= list
  { if |list| == 0 || !pred(list[|list| - 1]) then list
    else dropLastWhile(pred, list[..|list| - 1]) }

  // `R.takeLast(n, xs)` (v0.16.0): `drop(n >= 0 ? xs.length - n : 0, xs)`,
  // the last n elements: the whole list for n < 0 or n at least the length,
  // [] for 0 (`takeLast(2, [1, 2, 3])` is `[2, 3]`).
  function takeLast<T>(n: int, list: seq<T>): seq<T>
  { drop(if n >= 0 then |list| - n else 0, list) }

  // `R.takeLastWhile(fn, list)` (v0.16.0): as dropLastWhile, returning
  // `_slice(list, idx + 1, Infinity)`, the longest suffix whose elements
  // satisfy fn (`takeLastWhile(x => x > 2, [1, 3, 2, 4, 5])` is `[4, 5]`; an
  // array of characters for a JS string, the same seq here).
  function takeLastWhile<T>(fn: T -> bool, list: seq<T>): seq<T>
  { if |list| == 0 || !fn(list[|list| - 1]) then []
    else takeLastWhile(fn, list[..|list| - 1]) + [list[|list| - 1]] }

  // `R.splitEvery(n, list)` (v0.16.0): for n <= 0 it throws Error ("First
  // argument to splitEvery must be a positive integer"), so n is positive
  // (README "Outside the modeled domain"); otherwise `while (idx <
  // list.length) { result.push(slice(idx, idx += n, list)); }`, the
  // consecutive slices of n elements, the last one shorter when n does not
  // divide the length (`splitEvery(2, [1, 2, 3, 4, 5])` is `[[1, 2], [3, 4],
  // [5]]`; on a JS string, strings). The body takes the first slice and
  // recurses on the rest, as the loop does.
  function splitEvery<T>(n: int, list: seq<T>): seq<seq<T>>
    requires n > 0
    decreases |list|
  { if |list| == 0 then []
    else [slice(0, n, list)] + splitEvery(n, slice(n, |list|, list)) }

  // `R.uniqBy(fn, list)` (v0.16.0): keeps `list[idx]` unless `fn(list[idx])`
  // is already among the results of fn on the elements kept (`_contains`,
  // `R.equals`, which on Dafny values is `==`): the first element for each
  // value of fn, in list order (`uniqBy(Math.abs, [-1, -5, 2, 10, 1, 2])` is
  // `[-1, -5, 2, 10]`). The body recurses on all but the last element, as
  // the loop does.
  function uniqBy<T, U(==)>(fn: T -> U, list: seq<T>): seq<T>
  { if |list| == 0 then []
    else var r := uniqBy(fn, list[..|list| - 1]);
         if fn(list[|list| - 1]) in mapSeq(fn, r) then r else r + [list[|list| - 1]] }
}
