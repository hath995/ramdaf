// Ramdaf: Ramda v0.4.2 "List Functions" (ramda.js lines 1480-3206), except
// `comparator`/`sort` (Sort.dfy), `size`/`length` (Core.dfy) and `groupBy`
// (Data.dfy). (v0.4.1 removed the aliases `drop`, `nth`, `flatMap`,
// `flattenDeep` and `flattenShallow`, and renamed `all`/`any` to their
// aliases `every`/`some`.)

module Ramdaf.List {
  import opened Prelude

  export
    reveals foldl, reduce, foldlIdx, reduceIdx, foldr, reduceRight, foldrIdx,
            reduceRightIdx, unfoldr, mapSeq, mapIdx, mapObj, mapObjIdx, filter, filterIdx,
            reject, rejectIdx, takeWhile, take, skipUntil, skip, find,
            findIndex, findLast, findLastIndex, every, some, contains, containsWith,
            uniq, isSet, uniqWith, pluck, flatten, zipWith, zip, xprodWith, xprod, reverse,
            range, indexOf, indexOfFrom, lastIndexOf, lastIndexOfFrom, join, slice, sliceFrom,
            remove, insert, insertAll, partition,
            ap, of, empty, chain, unnest, zipObj, fromPairs
    provides Prelude

  // `acc = fn(acc, list[idx])` for idx ascending. Since v0.4.0 `reduce` holds
  // the definition (`var foldl = R.reduce = curry3(...)`, `@alias foldl`) and
  // `foldl` is the alias (`R.foldl = R.reduce`); until v0.3.0 it was the other
  // way round. The two keep the same contract.
  function reduce<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      reduce(fn, acc, list) == fn(reduce(fn, acc, list[..|list| - 1]), list[|list| - 1])
  { if |list| == 0 then acc
    else assert |list| > 1 ==> list[..|list| - 1][1..] == list[1..][..|list| - 2];
         reduce(fn, fn(acc, list[0]), list[1..]) }
  function foldl<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      foldl(fn, acc, list) == fn(foldl(fn, acc, list[..|list| - 1]), list[|list| - 1])
  { reduce(fn, acc, list) }

  // `reduce.idx` (v0.4.1 defines it as `R.reduce.idx` and sets
  // `R.foldl.idx = R.reduce.idx`; until v0.4.0 `foldl.idx` held it):
  // `acc = fn(acc, list[idx], idx, list)` for idx ascending. The body folds
  // over (element, index) pairs. The two keep the same contract.
  function reduceIdx<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A
    ensures |list| == 0 ==> reduceIdx(fn, acc, list) == acc
  { reduce((a: A, p: (B, nat)) => fn(a, p.0, p.1, list), acc, seq(|list|, i requires 0 <= i < |list| => (list[i], i as nat))) }
  function foldlIdx<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A
    ensures |list| == 0 ==> foldlIdx(fn, acc, list) == acc
  { reduceIdx(fn, acc, list) }

  // `acc = fn(acc, list[idx])` for idx descending: since v0.1.1 the
  // accumulator comes first, as in foldl, and the fold runs from the right, so
  // reduceRight(fn, acc, [x0, ..., xn]) is fn(... fn(fn(acc, xn), xn-1) ..., x0).
  // Since v0.4.1 `reduceRight` holds the definition and `foldr` is the alias
  // (`var foldr = R.foldr = R.reduceRight`); until v0.4.0 it was the other way
  // round. The two keep the same contract.
  function reduceRight<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      reduceRight(fn, acc, list) == reduceRight(fn, fn(acc, list[|list| - 1]), list[..|list| - 1])
  { if |list| == 0 then acc
    else assert |list| > 1 ==> list[..|list| - 1][1..] == list[1..][..|list| - 2];
         fn(reduceRight(fn, acc, list[1..]), list[0]) }
  function foldr<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      foldr(fn, acc, list) == foldr(fn, fn(acc, list[|list| - 1]), list[..|list| - 1])
  { reduceRight(fn, acc, list) }

  // `reduceRight.idx` (v0.4.1 defines it and sets `R.foldr.idx =
  // R.reduceRight.idx`; until v0.4.0 `foldr.idx` held it):
  // `acc = fn(acc, list[idx], idx, list)` for idx descending. The body folds
  // over (element, index) pairs. The two keep the same contract.
  function reduceRightIdx<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A
    ensures |list| == 0 ==> reduceRightIdx(fn, acc, list) == acc
  { reduceRight((a: A, p: (B, nat)) => fn(a, p.0, p.1, list), acc, seq(|list|, i requires 0 <= i < |list| => (list[i], i as nat))) }
  function foldrIdx<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A
    ensures |list| == 0 ==> foldrIdx(fn, acc, list) == acc
  { reduceRightIdx(fn, acc, list) }

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

  // `map.idx`: `fn(list[idx], idx, list)` for each index.
  function mapIdx<A, B>(fn: (A, nat, seq<A>) -> B, list: seq<A>): seq<B>
    ensures |mapIdx(fn, list)| == |list|
    ensures forall i :: 0 <= i < |list| ==> mapIdx(fn, list)[i] == fn(list[i], i, list)
  { seq(|list|, i requires 0 <= i < |list| => fn(list[i], i, list)) }

  // `foldl(function(acc, key) { acc[key] = fn(obj[key]); return acc; }, {}, keys(obj))`:
  // fn applied to every own property.
  function mapObj<V, W>(fn: V -> W, obj: map<string, V>): map<string, W>
    ensures mapObj(fn, obj).Keys == obj.Keys
    ensures forall k :: k in obj ==> mapObj(fn, obj)[k] == fn(obj[k])
  { map k | k in obj :: fn(obj[k]) }

  // `mapObj.idx` (v0.2.2): `fn(obj[key], key, obj)` for every own property.
  function mapObjIdx<V, W>(fn: (V, string, map<string, V>) -> W, obj: map<string, V>): map<string, W>
    ensures mapObjIdx(fn, obj).Keys == obj.Keys
    ensures forall k :: k in obj ==> mapObjIdx(fn, obj)[k] == fn(obj[k], k, obj)
  { map k | k in obj :: fn(obj[k], k, obj) }

  // `R.ap(fns, vs)` (v0.3.0): `foldl(function(acc, fn) { return concat(acc,
  // map(fn, vs)); }, [], fns)`, every function applied to every value, the
  // functions outermost (`ap([f, g], [1, 2])` is `[f(1), f(2), g(1), g(2)]`).
  // A non-array vs with an `ap` method is dispatched to (Fantasy-land); no
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

  function filter<T>(fn: T -> bool, list: seq<T>): seq<T>
    ensures |filter(fn, list)| <= |list|
    ensures forall i :: 0 <= i < |filter(fn, list)| ==> fn(filter(fn, list)[i])
    ensures forall i :: 0 <= i < |filter(fn, list)| ==> filter(fn, list)[i] in list
    ensures forall i :: 0 <= i < |list| && fn(list[i]) ==> list[i] in filter(fn, list)
    ensures multiset(filter(fn, list)) <= multiset(list)
  { if |list| == 0 then []
    else assert list == [list[0]] + list[1..];
         if fn(list[0]) then [list[0]] + filter(fn, list[1..]) else filter(fn, list[1..]) }

  // `filter.idx`: the elements list[idx] with `fn(list[idx], idx, list)`, in
  // list order. The body pairs each element with its index, filters the
  // pairs and keeps the elements.
  function filterIdx<T>(fn: (T, nat, seq<T>) -> bool, list: seq<T>): seq<T>
    ensures |filterIdx(fn, list)| <= |list|
    ensures forall k :: 0 <= k < |filterIdx(fn, list)| ==>
      exists i :: 0 <= i < |list| && list[i] == filterIdx(fn, list)[k] && fn(list[i], i, list)
    ensures forall i :: 0 <= i < |list| && fn(list[i], i, list) ==> list[i] in filterIdx(fn, list)
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

  // `reject.idx`: `filter.idx(notFn(fn), list)`, the elements list[idx] with
  // `!fn(list[idx], idx, list)`, in list order (the body is filter.idx's with
  // the test negated).
  function rejectIdx<T>(fn: (T, nat, seq<T>) -> bool, list: seq<T>): seq<T>
    ensures |rejectIdx(fn, list)| <= |list|
    ensures forall k :: 0 <= k < |rejectIdx(fn, list)| ==>
      exists i :: 0 <= i < |list| && list[i] == rejectIdx(fn, list)[k] && !fn(list[i], i, list)
    ensures forall i :: 0 <= i < |list| && !fn(list[i], i, list) ==> list[i] in rejectIdx(fn, list)
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

  // A copy of the list with its length set to `Math.min(n, list.length)`
  // (v0.1.5; before, `take(5, [1, 2])` had three undefined slots): the first
  // n elements, or the whole list. A negative n throws RangeError, so n is a
  // nat.
  function take<T>(n: nat, list: seq<T>): seq<T>
    ensures |take(n, list)| == if n <= |list| then n else |list|
    ensures take(n, list) <= list
  { if n <= |list| then list[..n] else list }

  // The suffix starting at the first element that satisfies fn.
  function skipUntil<T>(fn: T -> bool, list: seq<T>): seq<T>
    ensures |skipUntil(fn, list)| <= |list|
    ensures skipUntil(fn, list) == list[|list| - |skipUntil(fn, list)|..]
    ensures forall i :: 0 <= i < |list| - |skipUntil(fn, list)| ==> !fn(list[i])
    ensures |skipUntil(fn, list)| > 0 ==> fn(skipUntil(fn, list)[0])
  { if |list| == 0 || fn(list[0]) then list else skipUntil(fn, list[1..]) }

  // `_slice(list, n)`: all but the first n elements. Since v0.2.0 `_slice`
  // allocates `new Array(list.length - n)`, which throws RangeError when
  // n > |list| (`skip(5, [1, 2])`; it was [] before), so n is at most |list|.
  // A negative n gives JS garbage (`skip(-1, [1, 2])` is
  // `[undefined, 1, 2]`), so n is a nat.
  function skip<T>(n: nat, list: seq<T>): seq<T>
    requires n <= |list|
    ensures skip(n, list) == list[n..]
  { list[n..] }

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

  // v0.4.1 renames `all` to `every` (`R.every = curry2(every)`; `every` was
  // its alias), so the body is the one `all` had: fn holds for every element.
  function every<T>(fn: T -> bool, list: seq<T>): bool
  { forall i :: 0 <= i < |list| ==> fn(list[i]) }

  // v0.4.1 renames `any` to `some` likewise: fn holds for some element.
  function some<T>(fn: T -> bool, list: seq<T>): bool
  { exists i :: 0 <= i < |list| && fn(list[i]) }

  // `list.indexOf(a) > -1` (JS `===`; see README on equality).
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
  // `length`. A Leaf is never flattened, README "Deviations".)
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

  // Every pair, the first list's index outermost.
  function xprodWith<A, B, C>(fn: (A, B) -> C, a: seq<A>, b: seq<B>): seq<C>
    ensures |xprodWith(fn, a, b)| == |a| * |b|
  { if |a| == 0 || |b| == 0 then []
    else mapSeq((y: B) => fn(a[0], y), b) + xprodWith(fn, a[1..], b) }

  function xprod<A, B>(a: seq<A>, b: seq<B>): seq<(A, B)>
    ensures |xprod(a, b)| == |a| * |b|
  { xprodWith((x: A, y: B) => (x, y), a, b) }

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

  // `indexOf.from(target, fromIdx, list)` (v0.2.2): the search starts at
  // fromIdx, a negative fromIdx counting from the end (`Math.max(0, length +
  // fromIdx)`); -1 when target does not occur from there on. The body
  // searches the suffix with indexOf.
  function indexOfFrom<T(==)>(target: T, fromIdx: int, list: seq<T>): int
    ensures var i := if fromIdx < 0 then (if |list| + fromIdx < 0 then 0 else |list| + fromIdx)
                     else if fromIdx > |list| then |list| else fromIdx;
      -1 <= indexOfFrom(target, fromIdx, list) < |list| &&
      (indexOfFrom(target, fromIdx, list) == -1 <==> target !in list[i..]) &&
      (indexOfFrom(target, fromIdx, list) >= 0 ==>
         i <= indexOfFrom(target, fromIdx, list) && list[indexOfFrom(target, fromIdx, list)] == target &&
         forall j :: i <= j < indexOfFrom(target, fromIdx, list) ==> list[j] != target)
  { var i := if fromIdx < 0 then (if |list| + fromIdx < 0 then 0 else |list| + fromIdx)
             else if fromIdx > |list| then |list| else fromIdx;
    var r := indexOf(target, list[i..]);
    assert r >= 0 ==> list[i..][r] == list[i + r];
    assert forall j :: i <= j < i + r ==> list[j] == list[i..][j - i];
    if r == -1 then -1 else r + i }

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

  // `lastIndexOf.from(target, fromIdx, list)` (v0.2.2): the search runs
  // down from fromIdx, a negative fromIdx counting from the end (the loop
  // starts below `length + fromIdx + 1`, or below `Math.min(length,
  // fromIdx + 1)`); -1 when target does not occur at or before it. The body
  // searches the prefix with lastIndexOf.
  function lastIndexOfFrom<T(==)>(target: T, fromIdx: int, list: seq<T>): int
    ensures var e := if fromIdx < 0 then |list| + fromIdx + 1
                     else if fromIdx + 1 < |list| then fromIdx + 1 else |list|;
      -1 <= lastIndexOfFrom(target, fromIdx, list) < |list| &&
      (e <= 0 ==> lastIndexOfFrom(target, fromIdx, list) == -1) &&
      (e > 0 ==> (lastIndexOfFrom(target, fromIdx, list) == -1 <==> target !in list[..e])) &&
      (lastIndexOfFrom(target, fromIdx, list) >= 0 ==>
         lastIndexOfFrom(target, fromIdx, list) < e && list[lastIndexOfFrom(target, fromIdx, list)] == target &&
         forall j :: lastIndexOfFrom(target, fromIdx, list) < j < e ==> list[j] != target)
  { var e := if fromIdx < 0 then |list| + fromIdx + 1
             else if fromIdx + 1 < |list| then fromIdx + 1 else |list|;
    if e <= 0 then -1 else lastIndexOf(target, list[..e]) }

  // `list.join(sep)`; the elements are strings (see README on numbers).
  function join(sep: string, list: seq<string>): string
  { if |list| == 0 then ""
    else if |list| == 1 then list[0]
    else list[0] + sep + join(sep, list[1..]) }

  // `Array.prototype.slice(from, to)` (an invoker since v0.1.4): a negative
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

  // `slice.from = flip(slice)(undefined)`: `sliceFrom(from, list)` is
  // `list.slice(from)`, everything from `from` (clamped, negative from the end).
  function sliceFrom<T>(from: int, list: seq<T>): seq<T>
    ensures sliceFrom(from, list) == slice(from, |list|, list)
  { slice(from, |list|, list) }

  // `remove`, `insert` and `insert.all` (v0.2.2) are built on
  // `_slice(args, from, to)`, which copies args[from..to) into
  // `new Array(to - from)`: a negative length throws RangeError, and indices
  // past an end read undefined holes. From v0.2.2 to v0.2.3 `_slice` read an
  // end index of 0 as "the end" (`to || args.length`), so a cut at 0 copied
  // the whole list; v0.2.4 checks `typeof to === "number"` instead.

  // `concat(_slice(list, 0, Math.min(start, length)), _slice(list,
  // Math.min(length, start + count)))`: the list without `count` elements
  // from `start` (`remove(0, 2, [1, 2, 3, 4, 5])` is `[3, 4, 5]`; it was
  // `[1, 2, 3, 4, 5, 3, 4, 5]` before v0.2.4). A negative start throws
  // RangeError, and start + count < 0 reads undefined holes, so both are
  // excluded.
  function remove<T>(start: int, count: int, list: seq<T>): seq<T>
    requires 0 <= start
    requires 0 <= start + count
    ensures var a := if start < |list| then start else |list|;
      var b := if start + count < |list| then start + count else |list|;
      remove(start, count, list) == list[..a] + list[b..]
  { var a := if start < |list| then start else |list|;
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

  // `insert.all`: as insert, with the list elts in place of one element:
  // `concat(concat(_slice(list, 0, index), elts), _slice(list, index))`.
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
}
