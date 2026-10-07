// Ramdaf: Ramda v0.9.0 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "List Functions" section, except `comparator`/`sort`
// (Sort.dfy), `length` (Core.dfy) and `groupBy` (Data.dfy); from v0.9.0 on,
// the functions with `@category List` (`repeat`, `init`, `mapAccumL`,
// `mapAccumR` and the renamed functions below). (v0.4.1 removed the aliases
// `drop`, `nth`, `flatMap`, `flattenDeep` and `flattenShallow`, and renamed
// `all`/`any` to their aliases `every`/`some`; v0.8.0 removed `xprodWith`.
// v0.9.0 removed `reduce` and `reduceRight`, whose aliases `foldl` and
// `foldr` hold their code now, and `indexOf.from`, `lastIndexOf.from` and
// `slice.from`; it renamed the `.idx` properties to `*Indexed` functions,
// `skip` to `drop`, `every`/`some` to `all`/`any` and `insert.all` to
// `insertAll` (the name the port already used), and replaced `skipUntil`
// with `dropWhile`.)

module Ramdaf.List {
  import opened Prelude

  export
    reveals foldl, foldlIndexed, foldr, foldrIndexed, unfoldr, mapSeq, mapIndexed,
            mapObj, mapObjIndexed, filter, filterIndexed, reject, rejectIndexed,
            takeWhile, take, dropWhile, drop, find, findIndex, findLast, findLastIndex,
            all, any, contains, containsWith, uniq, isSet, uniqWith, pluck, flatten,
            zipWith, zip, lens, xprod, reverse, range, indexOf, lastIndexOf, join, slice,
            remove, insert, insertAll, partition,
            ap, of, empty, chain, commuteMap, commute, unnest, zipObj, fromPairs, scanl,
            createMapEntry, repeat, init, mapAccumL, mapAccumR
    provides Prelude

  // `_curry3(_foldl)` (`src/foldl.js`), `acc = fn(acc, list[idx])` for idx
  // ascending. v0.9.0 removed `reduce`, which held the definition from v0.4.0
  // to v0.8.0 with `foldl` its alias (until v0.3.0 `foldl` held it), so the
  // body is the recursion again.
  function foldl<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      foldl(fn, acc, list) == fn(foldl(fn, acc, list[..|list| - 1]), list[|list| - 1])
  { if |list| == 0 then acc
    else assert |list| > 1 ==> list[..|list| - 1][1..] == list[1..][..|list| - 2];
         foldl(fn, fn(acc, list[0]), list[1..]) }

  // `R.foldlIndexed` (v0.9.0, which renamed `foldl.idx`, the alias of
  // `reduce.idx` from v0.4.1 to v0.8.0, with the same code):
  // `acc = fn(acc, list[idx], idx, list)` for idx ascending. The body folds
  // over (element, index) pairs.
  function foldlIndexed<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A
    ensures |list| == 0 ==> foldlIndexed(fn, acc, list) == acc
  { foldl((a: A, p: (B, nat)) => fn(a, p.0, p.1, list), acc, seq(|list|, i requires 0 <= i < |list| => (list[i], i as nat))) }

  // `var idx = list.length; while (idx--) { acc = fn(acc, list[idx]); }`
  // (`src/foldr.js`): `acc = fn(acc, list[idx])` for idx descending. Since
  // v0.1.1 the accumulator comes first, as in foldl, and the fold runs from
  // the right, so foldr(fn, acc, [x0, ..., xn]) is
  // fn(... fn(fn(acc, xn), xn-1) ..., x0). v0.9.0 removed `reduceRight`, which
  // held the definition from v0.4.1 to v0.8.0 with `foldr` its alias, so the
  // body is the recursion again (and no longer dispatches to a
  // `reduceRight` method).
  function foldr<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      foldr(fn, acc, list) == foldr(fn, fn(acc, list[|list| - 1]), list[..|list| - 1])
  { if |list| == 0 then acc
    else assert |list| > 1 ==> list[..|list| - 1][1..] == list[1..][..|list| - 2];
         fn(foldr(fn, acc, list[1..]), list[0]) }

  // `R.foldrIndexed` (v0.9.0, which renamed `foldr.idx`, the alias of
  // `reduceRight.idx` from v0.4.1 to v0.8.0, with the same code):
  // `acc = fn(acc, list[idx], idx, list)` for idx descending. The body folds
  // over (element, index) pairs.
  function foldrIndexed<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A
    ensures |list| == 0 ==> foldrIndexed(fn, acc, list) == acc
  { foldr((a: A, p: (B, nat)) => fn(a, p.0, p.1, list), acc, seq(|list|, i requires 0 <= i < |list| => (list[i], i as nat))) }

  // `R.scanl(fn, acc, list)` (v0.7.0): `result[0] = acc; while (++idx < len)
  // { acc = fn(acc, list[idx - 1]); result[idx] = acc; }`, the accumulator
  // followed by each successive `fn(acc, x)` (fn gets exactly those two).
  function scanl<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): seq<A>
    ensures |scanl(fn, acc, list)| == |list| + 1
    ensures scanl(fn, acc, list)[0] == acc
  { [acc] + (if |list| == 0 then [] else scanl(fn, fn(acc, list[0]), list[1..])) }

  // JS loops until `fn` returns a falsy value (None here), possibly forever;
  // Dafny functions must terminate, so at most `fuel` elements are produced.
  function unfoldr<S, T>(fn: S -> Option<(T, S)>, seed: S, fuel: nat): seq<T>
    decreases fuel
    ensures |unfoldr(fn, seed, fuel)| <= fuel
  { if fuel == 0 then []
    else match fn(seed)
      case None => []
      case Some(pair) => [pair.0] + unfoldr(fn, pair.1, fuel - 1) }

  // `map` is a Dafny keyword, so Ramda's `map` is named mapSeq.
  function mapSeq<A, B>(fn: A -> B, list: seq<A>): seq<B>
    ensures |mapSeq(fn, list)| == |list|
    ensures forall i :: 0 <= i < |list| ==> mapSeq(fn, list)[i] == fn(list[i])
  { seq(|list|, i requires 0 <= i < |list| => fn(list[i])) }

  // `R.mapIndexed` (v0.9.0, which renamed `map.idx` with the same code):
  // `fn(list[idx], idx, list)` for each index.
  function mapIndexed<A, B>(fn: (A, nat, seq<A>) -> B, list: seq<A>): seq<B>
    ensures |mapIndexed(fn, list)| == |list|
    ensures forall i :: 0 <= i < |list| ==> mapIndexed(fn, list)[i] == fn(list[i], i, list)
  { seq(|list|, i requires 0 <= i < |list| => fn(list[i], i, list)) }

  // `_foldl(function(acc, key) { acc[key] = fn(obj[key]); return acc; }, {}, keys(obj))`
  // (`foldl` until v0.8.0, the same function):
  // fn applied to every own property. (In JS an own `__proto__` property is
  // dropped, as the assignment sets the prototype; README "Deviations".)
  function mapObj<V, W>(fn: V -> W, obj: map<string, V>): map<string, W>
    ensures mapObj(fn, obj).Keys == obj.Keys
    ensures forall k :: k in obj ==> mapObj(fn, obj)[k] == fn(obj[k])
  { map k | k in obj :: fn(obj[k]) }

  // `R.mapObjIndexed` (v0.9.0, which renamed `mapObj.idx`, added in v0.2.2,
  // with the same code): `fn(obj[key], key, obj)` for every own property
  // (an own `__proto__` dropped in JS, as for mapObj).
  function mapObjIndexed<V, W>(fn: (V, string, map<string, V>) -> W, obj: map<string, V>): map<string, W>
    ensures mapObjIndexed(fn, obj).Keys == obj.Keys
    ensures forall k :: k in obj ==> mapObjIndexed(fn, obj)[k] == fn(obj[k], k, obj)
  { map k | k in obj :: fn(obj[k], k, obj) }

  // `R.ap(fns, vs)` (v0.3.0): `foldl(function(acc, fn) { return concat(acc,
  // map(fn, vs)); }, [], fns)` (since v0.9.0 `_ap`, with `_foldl`), every
  // function applied to every value, the functions outermost
  // (`ap([f, g], [1, 2])` is `[f(1), f(2), g(1), g(2)]`). A non-array object with an `ap` method is dispatched to (Fantasy-land;
  // since v0.5.0 the first argument, `fns.ap(vs)`, before that `vs`); no
  // Dafny value has one.
  function ap<A, B>(fns: seq<A -> B>, vs: seq<A>): seq<B>
  { foldl((acc: seq<B>, fn: A -> B) => acc + mapSeq(fn, vs), [], fns) }

  // `R.of(x, container)` (v0.3.0): `[x]`, unless container has an `of`
  // method, which is then called (Fantasy-land); any other container is
  // ignored (`of(1, [9])` is `[1]`). The port drops container (README
  // "Deviations").
  function of<T>(x: T): seq<T> { [x] }

  // `R.empty(x)` (v0.3.0): `[]`, unless x has an `empty` method, which is
  // then called (Fantasy-land). JS takes any argument (`empty(5)` is `[]`);
  // here it is a list, whose element type the result shares (README
  // "Deviations").
  function empty<T>(x: seq<T>): seq<T> { [] }

  // `R.chain(f, list)` (v0.3.0): `unnest(map(f, list))`, f mapped over the
  // list and its results concatenated, one level deep. A non-array list with
  // a `chain` method is dispatched to. f returns a list here; JS keeps a
  // result that is not array-like (a number, a string) as one element
  // (README "Deviations"). The body concatenates the mapped lists.
  function chain<A, B>(f: A -> seq<B>, list: seq<A>): seq<B>
  { foldl((acc: seq<B>, xs: seq<B>) => acc + xs, [], mapSeq(f, list)) }

  // `R.commuteMap(fn, of, list)` (v0.8.0): `_foldl(consF, of([]), list)`
  // with `consF(acc, ftor) = _ap(_map(append, fn(ftor)), acc)` (v0.9.0;
  // v0.8.0 folded with `reduce`, which v0.9.0 removed, and called `R.ap` and
  // `R.map`), which turns a
  // list of functors into a functor of lists, fn transforming each functor
  // first. For arrays: every way of picking one element of fn(ftor) for each
  // ftor, the first list's element varying fastest (`commuteMap(map(x => x +
  // 10), of, [[1, 2], [3]])` is `[[11, 13], [12, 13]]`). JS dispatches `ap`
  // and `map` to any Fantasy-land functor, with of building the result's
  // functor (since v0.9.0 only `of`'s functor and its `ap`); here they are
  // arrays (README "Deviations"). `R.append` (Core) is written out as
  // `l + [x]`.
  function commuteMap<A, B>(fn: seq<A> -> seq<B>, of: seq<B> -> seq<seq<B>>, list: seq<seq<A>>): seq<seq<B>>
  { foldl((acc: seq<seq<B>>, ftor: seq<A>) => ap(mapSeq((x: B) => ((l: seq<B>) => l + [x]), fn(ftor)), acc),
           of([]), list) }

  // `R.commute = commuteMap(map(identity))` (v0.8.0): commuteMap with no
  // transformation (`commute(of, [[1, 2], [3, 4]])` is `[[1, 3], [2, 3],
  // [1, 4], [2, 4]]`). `R.identity` (Core) is written out as `x => x`.
  function commute<A>(of: seq<A> -> seq<seq<A>>, list: seq<seq<A>>): seq<seq<A>>
  { commuteMap((xs: seq<A>) => mapSeq((x: A) => x, xs), of, list) }

  function filter<T>(fn: T -> bool, list: seq<T>): seq<T>
    ensures |filter(fn, list)| <= |list|
    ensures forall i :: 0 <= i < |filter(fn, list)| ==> fn(filter(fn, list)[i])
    ensures forall i :: 0 <= i < |filter(fn, list)| ==> filter(fn, list)[i] in list
    ensures forall i :: 0 <= i < |list| && fn(list[i]) ==> list[i] in filter(fn, list)
    ensures multiset(filter(fn, list)) <= multiset(list)
  { if |list| == 0 then []
    else assert list == [list[0]] + list[1..];
         if fn(list[0]) then [list[0]] + filter(fn, list[1..]) else filter(fn, list[1..]) }

  // `R.filterIndexed` (v0.9.0, which renamed `filter.idx` with the same
  // code): the elements list[idx] with `fn(list[idx], idx, list)`, in
  // list order. The body pairs each element with its index, filters the
  // pairs and keeps the elements.
  function filterIndexed<T>(fn: (T, nat, seq<T>) -> bool, list: seq<T>): seq<T>
    ensures |filterIndexed(fn, list)| <= |list|
    ensures forall k :: 0 <= k < |filterIndexed(fn, list)| ==>
      exists i :: 0 <= i < |list| && list[i] == filterIndexed(fn, list)[k] && fn(list[i], i, list)
    ensures forall i :: 0 <= i < |list| && fn(list[i], i, list) ==> list[i] in filterIndexed(fn, list)
  { var pairs: seq<(T, nat)> := seq(|list|, i requires 0 <= i < |list| => (list[i], i as nat));
    var kept := filter((p: (T, nat)) => fn(p.0, p.1, list), pairs);
    assert forall k :: 0 <= k < |kept| ==>
      kept[k].1 < |list| && list[kept[k].1] == kept[k].0 && fn(kept[k].0, kept[k].1, list) by {
      forall k | 0 <= k < |kept|
        ensures kept[k].1 < |list| && list[kept[k].1] == kept[k].0 && fn(kept[k].0, kept[k].1, list) {
        assert kept[k] in pairs;
      }
    }
    assert forall i :: 0 <= i < |list| && fn(list[i], i, list) ==> pairs[i] in kept;
    var r := mapSeq((p: (T, nat)) => p.0, kept);
    assert forall k :: 0 <= k < |r| ==>
      exists i :: 0 <= i < |list| && list[i] == r[k] && fn(list[i], i, list) by {
      forall k | 0 <= k < |r| ensures exists i :: 0 <= i < |list| && list[i] == r[k] && fn(list[i], i, list) {
        var i := kept[k].1;
        assert 0 <= i < |list| && list[i] == r[k] && fn(list[i], i, list);
      }
    }
    r }

  // `filter(notFn(fn), list)`
  function reject<T>(fn: T -> bool, list: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |reject(fn, list)| ==> !fn(reject(fn, list)[i])
    ensures forall i :: 0 <= i < |reject(fn, list)| ==> reject(fn, list)[i] in list
    ensures forall i :: 0 <= i < |list| && !fn(list[i]) ==> list[i] in reject(fn, list)
  { filter(x => !fn(x), list) }

  // `R.rejectIndexed` (v0.9.0, which renamed `reject.idx` with the same
  // code): `_filterIndexed(not(fn), list)`, the elements list[idx] with
  // `!fn(list[idx], idx, list)`, in list order (the body is filterIndexed's
  // with the test negated).
  function rejectIndexed<T>(fn: (T, nat, seq<T>) -> bool, list: seq<T>): seq<T>
    ensures |rejectIndexed(fn, list)| <= |list|
    ensures forall k :: 0 <= k < |rejectIndexed(fn, list)| ==>
      exists i :: 0 <= i < |list| && list[i] == rejectIndexed(fn, list)[k] && !fn(list[i], i, list)
    ensures forall i :: 0 <= i < |list| && !fn(list[i], i, list) ==> list[i] in rejectIndexed(fn, list)
  { var pairs: seq<(T, nat)> := seq(|list|, i requires 0 <= i < |list| => (list[i], i as nat));
    var kept := filter((p: (T, nat)) => !fn(p.0, p.1, list), pairs);
    assert forall k :: 0 <= k < |kept| ==>
      kept[k].1 < |list| && list[kept[k].1] == kept[k].0 && !fn(kept[k].0, kept[k].1, list) by {
      forall k | 0 <= k < |kept|
        ensures kept[k].1 < |list| && list[kept[k].1] == kept[k].0 && !fn(kept[k].0, kept[k].1, list) {
        assert kept[k] in pairs;
      }
    }
    assert forall i :: 0 <= i < |list| && !fn(list[i], i, list) ==> pairs[i] in kept;
    var r := mapSeq((p: (T, nat)) => p.0, kept);
    assert forall k :: 0 <= k < |r| ==>
      exists i :: 0 <= i < |list| && list[i] == r[k] && !fn(list[i], i, list) by {
      forall k | 0 <= k < |r| ensures exists i :: 0 <= i < |list| && list[i] == r[k] && !fn(list[i], i, list) {
        var i := kept[k].1;
        assert 0 <= i < |list| && list[i] == r[k] && !fn(list[i], i, list);
      }
    }
    r }

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

  // `_slice(list, 0, Math.min(n, list.length))` (v0.3.0; v0.1.5 set a
  // copy's length to that; before, `take(5, [1, 2])` had three undefined
  // slots): the first n elements, or the whole list. Since v0.8.0 `_slice`
  // allocates `Math.max(0, to - from)` elements, so a negative n gives []
  // (`take(-1, [1, 2, 3])`); until v0.7.2 it threw RangeError, and n was a
  // nat.
  function take<T>(n: int, list: seq<T>): seq<T>
    ensures |take(n, list)| == if n < 0 then 0 else if n <= |list| then n else |list|
    ensures take(n, list) <= list
  { if n < 0 then [] else if n <= |list| then list[..n] else list }

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
  // `if (n < list.length) { return _slice(list, n); } else { return []; }`
  // (v0.5.0, "Fix a bug in R.skip"): all but the first n elements, or [] when
  // n is at least the length. From v0.2.0 to v0.4.3 `_slice` allocated
  // `new Array(list.length - n)`, which threw RangeError for n > |list|
  // (`skip(5, [1, 2])`), so n was at most |list|; before v0.2.0 it was [].
  // A negative n gives JS garbage (`drop(-1, [1, 2])` is
  // `[undefined, 1, 2]`), so n is a nat.
  function drop<T>(n: nat, list: seq<T>): seq<T>
    ensures n <= |list| ==> drop(n, list) == list[n..]
    ensures n >= |list| ==> drop(n, list) == []
  { if n < |list| then list[n..] else [] }

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

  // `list.indexOf(a) > -1` (JS `===`; see README on equality; since v0.9.0
  // `op`-curried, which only adds the placeholder form `contains(__, list)`).
  function contains<T(==)>(a: T, list: seq<T>): bool { a in list }

  // `pred(x, list[idx])` for some idx (exported since v0.1.5).
  function containsWith<T>(pred: (T, T) -> bool, x: T, list: seq<T>): bool
  { exists i :: 0 <= i < |list| && pred(x, list[i]) }

  // `var result = []; ... if (!contains(item, result)) result.push(item);`
  // for each item in order (v0.2.4; until v0.2.3 a foldr from the right kept
  // the LAST occurrences): each element at its FIRST occurrence, in list
  // order (`uniq([1, 2, 1, 3, 2]) == [1, 2, 3]`). The body recurses on all
  // but the last element and then decides the last one, which is the loop.
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
  // checks `indexOf(list, list[i], i + 1) < 0` for every i; until v0.2.3 it
  // was `uniq(list).length === list.length`, the same result.)
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

  // `map(prop(p), list)`: a missing property is JS undefined, here None.
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

  // `R.lens(get, set)` (v0.8.0; defined in "List Functions", hence here): a
  // function `lns(a) = get(a)` with the properties `lns.set = set` and
  // `lns.map = (fn, a) => set(fn(get(a)), a)`, here the record
  // `Prelude.Lens` (README "Deviations"; `set` is a Dafny keyword). get and
  // set_ are partial arrows, so a getter or setter that is undefined on part
  // of its domain carries a precondition; map_ requires get's on a and
  // set_'s on the mapped value.
  function lens<A, V>(get: A --> V, set_: (V, A) --> A): Lens<A, V>
  { Lens(get, set_, (fn: V -> V, a: A) requires get.requires(a) && set_.requires(fn(get(a)), a) =>
                      set_(fn(get(a)), a)) }

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

  // `list.indexOf(obj)`: the first index of obj, or -1.
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

  // `list.lastIndexOf(obj)`: the last index of obj, or -1.
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
  // Dafny "b"): a negative
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
  // was `[1, 2, 3, 9, 1, 2, 3]` before v0.2.4).
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

  // `foldl(function(acc, elt) { acc[pred(elt) ? 0 : 1].push(elt); return acc; }, [[], []], list)`
  // (v0.3.0, "like its Haskell namesake"): the pair of the elements that
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

  // `R.mapAccumL(fn, acc, list)` (v0.9.0): `tuple = [acc]; while (++idx <
  // len) { tuple = fn(tuple[0], list[idx]); result[idx] = tuple[1]; }
  // return [tuple[0], result];`, threading the accumulator left to right
  // through fn, which returns the pair [accumulator, mapped element].
  function mapAccumL<A, B, C>(fn: (A, B) -> (A, C), acc: A, list: seq<B>): (A, seq<C>)
    ensures |mapAccumL(fn, acc, list).1| == |list|
  { if |list| == 0 then (acc, [])
    else var t := fn(acc, list[0]);
         var r := mapAccumL(fn, t.0, list[1..]);
         (r.0, [t.1] + r.1) }

  // `R.mapAccumR(fn, acc, list)` (v0.9.0): as mapAccumL with idx descending,
  // `result[idx] = tuple[1]`, so each mapped element stays at its element's
  // index while the accumulator runs right to left.
  function mapAccumR<A, B, C>(fn: (A, B) -> (A, C), acc: A, list: seq<B>): (A, seq<C>)
    ensures |mapAccumR(fn, acc, list).1| == |list|
  { if |list| == 0 then (acc, [])
    else var t := fn(acc, list[|list| - 1]);
         var r := mapAccumR(fn, t.0, list[..|list| - 1]);
         (r.0, r.1 + [t.1]) }
}
