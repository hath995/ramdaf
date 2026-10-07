// Ramdaf: Ramda v0.7.0 "Data Analysis and Grouping Functions" (ramda.js lines
// 5246-5659), except `propEq` (Object.dfy), `sortBy` (Sort.dfy) and the
// unportable `functions`/`functionsIn`, and `groupBy`, which since v0.3.0 is
// defined in "List Functions" (line 3360 in v0.7.0; from v0.2.0 to v0.2.4 an
// alias of `partition` there) but which stays here (functions do not move
// between modules).
//
// The set functions are `uniq`/`uniqWith` of a combined or filtered list, as
// in Ramda, so they follow those functions: since v0.2.4 each element (each
// class, for the `*With` functions) is kept at its FIRST occurrence. (Until
// v0.2.3 `uniq` and `uniqWith` kept the last one, and the `*With` functions
// here carried `uniqWith`'s right-to-left recursion themselves.) Since v0.7.0
// `difference` and `differenceWith` are their own loops, with the same
// results.

module Ramdaf.Data {
  import opened Prelude
  import List
  import Object

  export
    reveals union, unionWith, difference, differenceWith,
            intersection, intersectionWith, countBy, groupBy, project
    provides Prelude, List, Object

  // `compose(uniq, R.concat)` (`merge` before v0.2.4): the elements of both
  // lists, each kept at its first occurrence (`union([1, 2, 3], [1]) ==
  // [1, 2, 3]`; it was `[2, 3, 1]` until v0.2.3).
  function union<T(==)>(list1: seq<T>, list2: seq<T>): seq<T>
  { List.uniq(list1 + list2) }

  // `uniqWith(pred, concat(list1, list2))`.
  function unionWith<T>(pred: (T, T) -> bool, list1: seq<T>, list2: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |unionWith(pred, list1, list2)| ==>
      unionWith(pred, list1, list2)[i] in list1 + list2
    ensures forall i, j :: 0 <= i < j < |unionWith(pred, list1, list2)| ==>
      !pred(unionWith(pred, list1, list2)[j], unionWith(pred, list1, list2)[i])
    ensures forall x | x in list1 + list2 ::
      x in unionWith(pred, list1, list2) ||
      exists j :: 0 <= j < |unionWith(pred, list1, list2)| && pred(x, unionWith(pred, list1, list2)[j])
  { List.uniqWith(pred, list1 + list2) }

  // `if (indexOf(second, first[idx]) === -1 && indexOf(out, first[idx]) ===
  // -1) out.push(first[idx])` for idx ascending (v0.7.0; before, it was
  // `uniq(reject(flip(contains)(second), first))`, with the same results):
  // the elements of first not in second, each kept at its first occurrence.
  // The body recurses on all but the last element, as the loop does.
  function difference<T(==)>(first: seq<T>, second: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |difference(first, second)| ==>
      difference(first, second)[i] in first && difference(first, second)[i] !in second
    ensures forall i :: 0 <= i < |first| && first[i] !in second ==> first[i] in difference(first, second)
  { if |first| == 0 then []
    else var init := first[..|first| - 1];
         var x := first[|first| - 1];
         var out := difference(init, second);
         assert forall y | y in first :: y == x || y in init;
         assert forall i :: 0 <= i < |init| ==> init[i] == first[i];
         if x !in second && x !in out then out + [x] else out }

  // `if (!containsPred(first[idx], second) && !containsPred(first[idx], out))
  // out.push(first[idx])` with `containsPred = R.containsWith(pred)` (v0.7.0;
  // before, it was `uniqWith(pred)(reject(flip(containsWith(pred))(second),
  // first))`, with the same results): x is kept unless `pred(x, y)` holds for
  // some y in second or for some element already kept.
  function differenceWith<T>(pred: (T, T) -> bool, first: seq<T>, second: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |differenceWith(pred, first, second)| ==>
      differenceWith(pred, first, second)[i] in first &&
      forall j :: 0 <= j < |second| ==> !pred(differenceWith(pred, first, second)[i], second[j])
    ensures forall i, j :: 0 <= i < j < |differenceWith(pred, first, second)| ==>
      !pred(differenceWith(pred, first, second)[j], differenceWith(pred, first, second)[i])
  { if |first| == 0 then []
    else var init := first[..|first| - 1];
         var x := first[|first| - 1];
         var out := differenceWith(pred, init, second);
         assert forall y | y in init :: y in first;
         if !List.containsWith(pred, x, second) && !List.containsWith(pred, x, out) then
           var r := out + [x];
           assert forall k :: 0 <= k < |out| ==> r[k] == out[k];
           r
         else out }

  // `uniq(filter(flip(contains)(list1), list2))`: the elements of list2 that
  // occur in list1, each kept at its first occurrence in list2 (since v0.1.1
  // the order follows list2: `intersection([1, 2, 3, 4], [4, 3, 2]) ==
  // [4, 3, 2]`).
  function intersection<T(==)>(list1: seq<T>, list2: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |intersection(list1, list2)| ==>
      intersection(list1, list2)[i] in list1 && intersection(list1, list2)[i] in list2
    ensures forall i :: 0 <= i < |list2| && list2[i] in list1 ==> list2[i] in intersection(list1, list2)
    ensures forall i, j :: 0 <= i < j < |intersection(list1, list2)| ==>
      intersection(list1, list2)[i] != intersection(list1, list2)[j]
  { List.uniq(List.filter(x => x in list1, list2)) }

  // `uniqWith(pred, results)`, where results are the elements x of list1 with
  // `pred(x, y)` for some y in list2 (`containsWith(pred, x, list2)`).
  function intersectionWith<T>(pred: (T, T) -> bool, list1: seq<T>, list2: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |intersectionWith(pred, list1, list2)| ==>
      intersectionWith(pred, list1, list2)[i] in list1 &&
      exists j :: 0 <= j < |list2| && pred(intersectionWith(pred, list1, list2)[i], list2[j])
    ensures forall i, j :: 0 <= i < j < |intersectionWith(pred, list1, list2)| ==>
      !pred(intersectionWith(pred, list1, list2)[j], intersectionWith(pred, list1, list2)[i])
  { var results := List.filter(x => List.containsWith(pred, x, list2), list1);
    var r := List.uniqWith(pred, results);
    assert forall i :: 0 <= i < |r| ==> r[i] in results;
    r }

  // For each key fn produces, how many elements produce it. In JS a key that
  // names an `Object.prototype` member (`__proto__`, `hasOwnProperty`) is not
  // an ordinary property; here every key is (README "Deviations").
  function countBy<T>(fn: T -> string, list: seq<T>): map<string, nat>
  { var keys := set i | 0 <= i < |list| :: fn(list[i]);
    map k | k in keys :: |List.filter(x => fn(x) == k, list)| }

  // `foldl(function(acc, elt) { var key = fn(elt); acc[key] = append(elt, acc[key] || []); ... }, {}, list)`
  // (v0.3.0, which makes groupBy its own function again with the body that
  // partition, its original since v0.2.0, had; partition now splits by a
  // predicate): for each key fn produces, the elements that produce it, in
  // list order. The results are unchanged. As for countBy, a key that names
  // an `Object.prototype` member is an ordinary key here (README
  // "Deviations").
  function groupBy<T>(fn: T -> string, list: seq<T>): map<string, seq<T>>
    ensures groupBy(fn, list).Keys == set i | 0 <= i < |list| :: fn(list[i])
    ensures forall k :: k in groupBy(fn, list) ==> groupBy(fn, list)[k] == List.filter(x => fn(x) == k, list)
  { var keys := set i | 0 <= i < |list| :: fn(list[i]);
    map k | k in keys :: List.filter(x => fn(x) == k, list) }

  // `useWith(map, pickAll, identity)`: `map(pickAll(names), list)` (in JS an
  // own `__proto__` property is dropped, as for pickAll).
  function project<V>(names: seq<string>, list: seq<map<string, V>>): seq<map<string, Option<V>>>
  { List.mapSeq((obj: map<string, V>) => Object.pickAll(names, obj), list) }
}
