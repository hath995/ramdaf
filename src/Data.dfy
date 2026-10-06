// Ramdaf: Ramda v0.1.1 "Data Analysis and Grouping Functions" (ramda.js lines
// 1405-1508), except `propEq` (Object.dfy) and `sortBy` (Sort.dfy).
//
// Ramda's `uniqWith` and `containsWith` are internal in v0.1.1 (not on `R`),
// so the `*With` functions below carry their own recursion: each is
// `uniqWith(pred, ...)` unrolled, where `uniqWith` scans from the right and
// drops x when `pred(x, y)` holds for an element y it already kept.

module Ramdaf.Data {
  import opened Prelude
  import List
  import Object

  export
    reveals union, unionWith, difference, differenceWith,
            intersection, intersectionWith, countBy, groupBy, project
    provides Prelude, List, Object

  // `compose(uniq, merge)`: the elements of both lists, each kept at its last
  // occurrence (`union([1, 2, 3], [1]) == [2, 3, 1]`).
  function union<T(==)>(list1: seq<T>, list2: seq<T>): seq<T>
  { List.uniq(list1 + list2) }

  // `uniqWith(pred, merge(list1, list2))`; `unionWith(pred, xs, [])` is
  // `uniqWith(pred, xs)`.
  function unionWith<T>(pred: (T, T) -> bool, list1: seq<T>, list2: seq<T>): seq<T>
    decreases |list1| + |list2|
    ensures forall i :: 0 <= i < |unionWith(pred, list1, list2)| ==>
      unionWith(pred, list1, list2)[i] in list1 + list2
    ensures forall i, j :: 0 <= i < j < |unionWith(pred, list1, list2)| ==>
      !pred(unionWith(pred, list1, list2)[i], unionWith(pred, list1, list2)[j])
    ensures forall x | x in list1 + list2 ::
      x in unionWith(pred, list1, list2) ||
      exists j :: 0 <= j < |unionWith(pred, list1, list2)| && pred(x, unionWith(pred, list1, list2)[j])
  { var list := list1 + list2;
    if |list| == 0 then []
    else var acc := unionWith(pred, list[1..], []);
         assert list[1..] + [] == list[1..];
         assert forall x | x in list :: x == list[0] || x in list[1..];
         if exists j :: 0 <= j < |acc| && pred(list[0], acc[j]) then acc
         else var r := [list[0]] + acc;
              assert forall j :: 0 <= j < |acc| ==> r[j + 1] == acc[j];
              assert forall x | x in acc :: x in r;
              r }

  // `uniq(reject(flip(contains)(second))(first))`
  function difference<T(==)>(first: seq<T>, second: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |difference(first, second)| ==>
      difference(first, second)[i] in first && difference(first, second)[i] !in second
    ensures forall i :: 0 <= i < |first| && first[i] !in second ==> first[i] in difference(first, second)
  { List.uniq(List.reject(x => List.contains(x, second), first)) }

  // `uniqWith(pred)(reject(flip(containsWith(pred))(second), first))`
  function differenceWith<T>(pred: (T, T) -> bool, first: seq<T>, second: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |differenceWith(pred, first, second)| ==>
      differenceWith(pred, first, second)[i] in first &&
      forall j :: 0 <= j < |second| ==> !pred(differenceWith(pred, first, second)[i], second[j])
    ensures forall i, j :: 0 <= i < j < |differenceWith(pred, first, second)| ==>
      !pred(differenceWith(pred, first, second)[i], differenceWith(pred, first, second)[j])
  { if |first| == 0 then []
    else var acc := differenceWith(pred, first[1..], second);
         if (exists j :: 0 <= j < |second| && pred(first[0], second[j])) ||
            (exists j :: 0 <= j < |acc| && pred(first[0], acc[j]))
         then acc else [first[0]] + acc }

  // `uniq(filter(flip(contains)(list1), list2))`: the elements of list2 that
  // occur in list1, each kept at its last occurrence in list2 (since v0.1.1
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
  // `pred(x, y)` for some y in list2.
  function intersectionWith<T>(pred: (T, T) -> bool, list1: seq<T>, list2: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |intersectionWith(pred, list1, list2)| ==>
      intersectionWith(pred, list1, list2)[i] in list1 &&
      exists j :: 0 <= j < |list2| && pred(intersectionWith(pred, list1, list2)[i], list2[j])
    ensures forall i, j :: 0 <= i < j < |intersectionWith(pred, list1, list2)| ==>
      !pred(intersectionWith(pred, list1, list2)[i], intersectionWith(pred, list1, list2)[j])
  { if |list1| == 0 then []
    else var acc := intersectionWith(pred, list1[1..], list2);
         if !(exists j :: 0 <= j < |list2| && pred(list1[0], list2[j])) ||
            (exists j :: 0 <= j < |acc| && pred(list1[0], acc[j]))
         then acc else [list1[0]] + acc }

  // For each key fn produces, how many elements produce it.
  function countBy<T>(fn: T -> string, list: seq<T>): map<string, nat>
  { var keys := set i | 0 <= i < |list| :: fn(list[i]);
    map k | k in keys :: |List.filter(x => fn(x) == k, list)| }

  // For each key fn produces, the elements that produce it, in list order.
  function groupBy<T>(fn: T -> string, list: seq<T>): map<string, seq<T>>
  { var keys := set i | 0 <= i < |list| :: fn(list[i]);
    map k | k in keys :: List.filter(x => fn(x) == k, list) }

  // `useWith(map, pickAll, identity)`: `map(pickAll(names), list)`.
  function project<V>(names: seq<string>, list: seq<map<string, V>>): seq<map<string, Option<V>>>
  { List.mapSeq((obj: map<string, V>) => Object.pickAll(names, obj), list) }
}
