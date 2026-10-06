// Ramdaf: Ramda v0.2.2 "List Functions" (ramda.js lines 557-1145), except
// `comparator`/`sort` (Sort.dfy) and `size` (Core.dfy).

module Ramdaf.List {
  import opened Prelude

  export
    reveals foldl, reduce, foldlIdx, reduceIdx, foldr, reduceRight, foldrIdx,
            reduceRightIdx, unfoldr, mapSeq, mapIdx, mapObj, mapObjIdx, filter, filterIdx,
            reject, rejectIdx, takeWhile, take, skipUntil, skip, drop, find,
            findIndex, findLast, findLastIndex, all, every, any, some, contains, containsWith,
            uniq, isSet, uniqWith, pluck, flatten, zipWith, zip, xprodWith, xprod, reverse,
            range, indexOf, indexOfFrom, lastIndexOf, lastIndexOfFrom, join, slice, sliceFrom,
            remove, insert, insertAll, nth, partition
    provides Prelude

  // `acc = fn(acc, list[idx])` for idx ascending.
  function foldl<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      foldl(fn, acc, list) == fn(foldl(fn, acc, list[..|list| - 1]), list[|list| - 1])
  { if |list| == 0 then acc
    else assert |list| > 1 ==> list[..|list| - 1][1..] == list[1..][..|list| - 2];
         foldl(fn, fn(acc, list[0]), list[1..]) }
  function reduce<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A { foldl(fn, acc, list) }

  // `foldl.idx` (alias `reduce.idx`): `acc = fn(acc, list[idx], idx, list)`
  // for idx ascending. The body folds over (element, index) pairs.
  function foldlIdx<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A
    ensures |list| == 0 ==> foldlIdx(fn, acc, list) == acc
  { foldl((a: A, p: (B, nat)) => fn(a, p.0, p.1, list), acc, seq(|list|, i requires 0 <= i < |list| => (list[i], i as nat))) }
  function reduceIdx<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A { foldlIdx(fn, acc, list) }

  // `acc = fn(acc, list[idx])` for idx descending: since v0.1.1 the
  // accumulator comes first, as in foldl, and the fold runs from the right, so
  // foldr(fn, acc, [x0, ..., xn]) is fn(... fn(fn(acc, xn), xn-1) ..., x0).
  function foldr<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A
    ensures |list| > 0 ==>
      foldr(fn, acc, list) == foldr(fn, fn(acc, list[|list| - 1]), list[..|list| - 1])
  { if |list| == 0 then acc
    else assert |list| > 1 ==> list[..|list| - 1][1..] == list[1..][..|list| - 2];
         fn(foldr(fn, acc, list[1..]), list[0]) }
  function reduceRight<A, B>(fn: (A, B) -> A, acc: A, list: seq<B>): A { foldr(fn, acc, list) }

  // `foldr.idx` (alias `reduceRight.idx`): `acc = fn(acc, list[idx], idx, list)`
  // for idx descending. The body folds over (element, index) pairs.
  function foldrIdx<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A
    ensures |list| == 0 ==> foldrIdx(fn, acc, list) == acc
  { foldr((a: A, p: (B, nat)) => fn(a, p.0, p.1, list), acc, seq(|list|, i requires 0 <= i < |list| => (list[i], i as nat))) }
  function reduceRightIdx<A, B>(fn: (A, B, nat, seq<B>) -> A, acc: A, list: seq<B>): A { foldrIdx(fn, acc, list) }

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

  // `while (++idx < len && fn(list[idx])) {}; return _slice(list, 0, idx);`
  // (v0.2.0): the longest prefix whose elements all satisfy fn, except that
  // `_slice` reads an end index of 0 as "the end" (`to || args.length`), so
  // when the first element fails fn the WHOLE list comes back
  // (`takeWhile(x => x > 5, [1, 2, 3])` is `[1, 2, 3]`). The body finds the
  // first failing index with findIndex (-1 when every element passes).
  function takeWhile<T>(fn: T -> bool, list: seq<T>): seq<T>
    ensures |list| > 0 && !fn(list[0]) ==> takeWhile(fn, list) == list
    ensures !(|list| > 0 && !fn(list[0])) ==>
      takeWhile(fn, list) <= list &&
      (forall i :: 0 <= i < |takeWhile(fn, list)| ==> fn(list[i])) &&
      (|takeWhile(fn, list)| < |list| ==> !fn(list[|takeWhile(fn, list)|]))
  { var i := findIndex(x => !fn(x), list);
    if i <= 0 then list else list[..i] }

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
  function drop<T>(n: nat, list: seq<T>): seq<T>
    requires n <= |list|
  { skip(n, list) }

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

  // `var idx = list.length; while (--idx) { if (fn(list[idx])) return list[idx]; }`.
  // The loop stops when idx reaches 0, so the first element is never tested
  // (`findLast(fn, [x])` is undefined even when fn(x) holds). On the empty
  // list idx runs -1, -2, ... and fn(undefined) is called until it is truthy,
  // which a predicate on T cannot express (it loops forever when it is falsy):
  // the empty list is excluded.
  function findLast<T>(fn: T -> bool, list: seq<T>): Option<T>
    requires |list| > 0
    ensures findLast(fn, list).Some? ==>
      exists i :: 1 <= i < |list| && list[i] == findLast(fn, list).value && fn(list[i]) &&
                  forall j :: i < j < |list| ==> !fn(list[j])
    ensures findLast(fn, list).None? <==> forall j :: 1 <= j < |list| ==> !fn(list[j])
  { if |list| == 1 then None
    else if fn(list[|list| - 1]) then Some(list[|list| - 1])
    else var r := findLast(fn, list[..|list| - 1]);
         assert forall j :: 1 <= j < |list| - 1 ==> list[..|list| - 1][j] == list[j];
         r }

  // As findLast, returning the index, or -1 when no tested element satisfies
  // fn (v0.2.0; it was undefined, here None, before): list index 0 is never
  // tested, and the empty list is excluded.
  function findLastIndex<T>(fn: T -> bool, list: seq<T>): int
    requires |list| > 0
    ensures findLastIndex(fn, list) == -1 || 1 <= findLastIndex(fn, list) < |list|
    ensures findLastIndex(fn, list) >= 1 ==>
      fn(list[findLastIndex(fn, list)]) &&
      forall j :: findLastIndex(fn, list) < j < |list| ==> !fn(list[j])
    ensures findLastIndex(fn, list) == -1 <==> forall j :: 1 <= j < |list| ==> !fn(list[j])
  { if |list| == 1 then -1
    else if fn(list[|list| - 1]) then |list| - 1
    else var r := findLastIndex(fn, list[..|list| - 1]);
         assert forall j :: 1 <= j < |list| - 1 ==> list[..|list| - 1][j] == list[j];
         r }

  function all<T>(fn: T -> bool, list: seq<T>): bool
  { forall i :: 0 <= i < |list| ==> fn(list[i]) }
  function every<T>(fn: T -> bool, list: seq<T>): bool { all(fn, list) }

  function any<T>(fn: T -> bool, list: seq<T>): bool
  { exists i :: 0 <= i < |list| && fn(list[i]) }
  function some<T>(fn: T -> bool, list: seq<T>): bool { any(fn, list) }

  // `list.indexOf(a) > -1` (JS `===`; see README on equality).
  function contains<T(==)>(a: T, list: seq<T>): bool { a in list }

  // `pred(x, list[idx])` for some idx (exported since v0.1.5).
  function containsWith<T>(pred: (T, T) -> bool, x: T, list: seq<T>): bool
  { exists i :: 0 <= i < |list| && pred(x, list[i]) }

  // `foldr(function(x, acc) { return contains(x, acc) ? acc : prepend(x, acc); }, [], list)`:
  // scanning from the right keeps the LAST occurrence of each element, in the
  // order of those last occurrences (`uniq([1, 2, 1, 3, 2]) == [1, 3, 2]`).
  function {:isolate_assertions} uniq<T(==)>(list: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |uniq(list)| ==> uniq(list)[i] in list
    ensures forall i :: 0 <= i < |list| ==> list[i] in uniq(list)
    ensures forall i, j :: 0 <= i < j < |uniq(list)| ==> uniq(list)[i] != uniq(list)[j]
    ensures forall i, j :: 0 <= i < j < |uniq(list)| ==>
      lastIndexOf(uniq(list)[i], list) < lastIndexOf(uniq(list)[j], list)
    ensures |list| > 0 ==>
      (uniq(list) == if list[0] in list[1..] then uniq(list[1..]) else [list[0]] + uniq(list[1..]))
  { if |list| == 0 then []
    else var acc := uniq(list[1..]);
         assert forall k :: 0 <= k < |acc| ==> acc[k] in list[1..];
         assert forall y :: y in list[1..] ==> lastIndexOf(y, list) == 1 + lastIndexOf(y, list[1..]) by {
           forall y | y in list[1..] ensures lastIndexOf(y, list) == 1 + lastIndexOf(y, list[1..]) {
             var p := lastIndexOf(y, list[1..]);
             var q := lastIndexOf(y, list);
             assert p != -1;
             assert 0 <= p < |list[1..]| && list[1..][p] == y;
             assert list[p + 1] == y;
             assert list[p + 1] in list;
             assert q != -1;
             if q < p + 1 { assert list[p + 1] != y; }
             if q > p + 1 { assert list[1..][q - 1] == y; }
           }
         }
         if list[0] in acc then acc
         else
           var r := [list[0]] + acc;
           assert lastIndexOf(list[0], list) == 0 by {
             var q := lastIndexOf(list[0], list);
             assert list[0] !in list[1..];
             if q > 0 { assert list[1..][q - 1] == list[0]; }
           }
           assert forall i, j :: 0 <= i < j < |r| ==> lastIndexOf(r[i], list) < lastIndexOf(r[j], list) by {
             forall i, j | 0 <= i < j < |r| ensures lastIndexOf(r[i], list) < lastIndexOf(r[j], list) {
               assert r[j] == acc[j - 1];
               if i > 0 { assert r[i] == acc[i - 1]; }
             }
           }
           r }

  // `uniq(list).length === list.length`: true exactly when no element occurs
  // twice, which is the body (uniq keeps one copy of each element).
  function isSet<T(==)>(list: seq<T>): bool
  { forall i, j :: 0 <= i < j < |list| ==> list[i] != list[j] }

  // `foldr(function(acc, x) { return containsWith(pred, x, acc) ? acc : prepend(x, acc); }, EMPTY, list)`
  // (exported since v0.2.0): scanning from the right, x is dropped when
  // `pred(x, y)` holds for an element y already kept, so each class keeps its
  // LAST representative (`uniqWith((a, b) => a % 3 == b % 3, [1, 2, 3, 4])`
  // is `[2, 3, 4]`).
  function uniqWith<T>(pred: (T, T) -> bool, list: seq<T>): seq<T>
    ensures |list| == 0 ==> uniqWith(pred, list) == []
    ensures |list| > 0 ==>
      uniqWith(pred, list) ==
        (if containsWith(pred, list[0], uniqWith(pred, list[1..])) then uniqWith(pred, list[1..])
         else [list[0]] + uniqWith(pred, list[1..]))
    ensures forall i :: 0 <= i < |uniqWith(pred, list)| ==> uniqWith(pred, list)[i] in list
    ensures forall i, j :: 0 <= i < j < |uniqWith(pred, list)| ==>
      !pred(uniqWith(pred, list)[i], uniqWith(pred, list)[j])
    ensures forall x | x in list ::
      x in uniqWith(pred, list) ||
      exists j :: 0 <= j < |uniqWith(pred, list)| && pred(x, uniqWith(pred, list)[j])
  { if |list| == 0 then []
    else var acc := uniqWith(pred, list[1..]);
         assert forall x | x in list :: x == list[0] || x in list[1..];
         if containsWith(pred, list[0], acc) then acc
         else var r := [list[0]] + acc;
              assert forall j :: 0 <= j < |acc| ==> r[j + 1] == acc[j];
              assert forall x | x in acc :: x in r;
              r }

  // `map(prop(p), list)`: a missing property is JS undefined, here None.
  function pluck<V>(p: string, list: seq<map<string, V>>): seq<Option<V>>
    ensures |pluck(p, list)| == |list|
  { mapSeq((obj: map<string, V>) => if p in obj then Some(obj[p]) else None, list) }

  // Depth-first, left-to-right concatenation of the leaves.
  function flatten<T>(list: seq<Tree<T>>): seq<T>
  { if |list| == 0 then []
    else (match list[0] case Leaf(v) => [v] case Node(c) => flatten(c)) + flatten(list[1..]) }

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

  // v0.2.2 replaces `splice` with `remove`, `insert` and `insert.all`, all
  // built on `_slice(args, from, to)`, which copies args[from..to) into
  // `new Array(to - from)` reading `from || 0` and `to || args.length`: an end
  // index of 0 reads as "the end" (so `_slice(list, 0, 0)` is the whole
  // list), a negative length throws RangeError, and indices past an end read
  // undefined holes.

  // `concat(_slice(list, 0, Math.min(start, length)), _slice(list,
  // Math.min(length, start + count)))`: the list without `count` elements
  // from `start`, except that when the first cut is 0 (start 0, or the empty
  // list) the whole list comes first (`remove(0, 2, [1, 2, 3, 4, 5])` is
  // `[1, 2, 3, 4, 5, 3, 4, 5]`). A negative start throws RangeError, and
  // start + count < 0 reads undefined holes, so both are excluded.
  function remove<T>(start: int, count: int, list: seq<T>): seq<T>
    requires 0 <= start
    requires 0 <= start + count
    ensures var a := if start < |list| then start else |list|;
      var b := if start + count < |list| then start + count else |list|;
      remove(start, count, list) == (if a == 0 then list else list[..a]) + list[b..]
  { var a := if start < |list| then start else |list|;
    var b := if start + count < |list| then start + count else |list|;
    (if a == 0 then list else list[..a]) + list[b..] }

  // `index` is used when `0 <= index < length` and is `length` (the end)
  // otherwise; then `concat(append(elt, _slice(list, 0, index)),
  // _slice(list, index))`. When index is 0 the first part is the whole list:
  // `insert(0, 9, [1, 2, 3])` is `[1, 2, 3, 9, 1, 2, 3]`.
  function insert<T>(index: int, elt: T, list: seq<T>): seq<T>
    ensures var i := if 0 <= index < |list| then index else |list|;
      insert(index, elt, list) == (if i == 0 then list else list[..i]) + [elt] + list[i..]
  { var i := if 0 <= index < |list| then index else |list|;
    (if i == 0 then list else list[..i]) + [elt] + list[i..] }

  // `insert.all`: as insert, with the list elts in place of one element:
  // `concat(concat(_slice(list, 0, index), elts), _slice(list, index))`.
  function insertAll<T>(index: int, elts: seq<T>, list: seq<T>): seq<T>
    ensures var i := if 0 <= index < |list| then index else |list|;
      insertAll(index, elts, list) == (if i == 0 then list else list[..i]) + elts + list[i..]
  { var i := if 0 <= index < |list| then index else |list|;
    (if i == 0 then list else list[..i]) + elts + list[i..] }

  // `list[n]`: undefined (None) out of range.
  function nth<T>(n: int, list: seq<T>): Option<T>
  { if 0 <= n < |list| then Some(list[n]) else None }

  // `foldl(function(acc, elt) { var key = fn(elt); acc[key] = append(elt, acc[key] || []); ... }, {}, list)`:
  // the elements grouped by the key fn gives them, each group in list order.
  // (Not a split into two lists: Ramda's own test groups students by grade.)
  function partition<T>(fn: T -> string, list: seq<T>): map<string, seq<T>>
    ensures partition(fn, list).Keys == set i | 0 <= i < |list| :: fn(list[i])
    ensures forall k :: k in partition(fn, list) ==> partition(fn, list)[k] == filter(x => fn(x) == k, list)
  { var keys := set i | 0 <= i < |list| :: fn(list[i]);
    map k | k in keys :: filter(x => fn(x) == k, list) }
}
