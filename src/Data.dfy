// Ramdaf: Ramda v0.2.4 "Data Analysis and Grouping Functions" (ramda.js lines
// 3190-3354), except `propEq` (Object.dfy) and `sortBy` (Sort.dfy), and
// `groupBy`, which v0.2.0 defines in "List Functions" as an alias of
// `partition` but which stays here (functions do not move between modules).
//
// The set functions are `uniq`/`uniqWith` of a combined or filtered list, as
// in Ramda, so they follow those functions: since v0.2.4 each element (each
// class, for the `*With` functions) is kept at its FIRST occurrence. (Until
// v0.2.3 `uniq` and `uniqWith` kept the last one, and the `*With` functions
// here carried `uniqWith`'s right-to-left recursion themselves.)

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

  // `uniq(reject(flip(contains)(second), first))`
  function difference<T(==)>(first: seq<T>, second: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |difference(first, second)| ==>
      difference(first, second)[i] in first && difference(first, second)[i] !in second
    ensures forall i :: 0 <= i < |first| && first[i] !in second ==> first[i] in difference(first, second)
  { List.uniq(List.reject(x => List.contains(x, second), first)) }

  // `uniqWith(pred)(reject(flip(containsWith(pred))(second), first))`: the
  // elements x of first with no y in second such that `pred(x, y)`, then
  // uniqWith.
  function differenceWith<T>(pred: (T, T) -> bool, first: seq<T>, second: seq<T>): seq<T>
    ensures forall i :: 0 <= i < |differenceWith(pred, first, second)| ==>
      differenceWith(pred, first, second)[i] in first &&
      forall j :: 0 <= j < |second| ==> !pred(differenceWith(pred, first, second)[i], second[j])
    ensures forall i, j :: 0 <= i < j < |differenceWith(pred, first, second)| ==>
      !pred(differenceWith(pred, first, second)[j], differenceWith(pred, first, second)[i])
  { var kept := List.reject(x => List.containsWith(pred, x, second), first);
    var r := List.uniqWith(pred, kept);
    assert forall i :: 0 <= i < |r| ==> r[i] in kept;
    r }

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

  // For each key fn produces, how many elements produce it.
  function countBy<T>(fn: T -> string, list: seq<T>): map<string, nat>
  { var keys := set i | 0 <= i < |list| :: fn(list[i]);
    map k | k in keys :: |List.filter(x => fn(x) == k, list)| }

  // v0.2.0: `aliasFor("partition").is("groupBy")`. partition groups by the
  // string key fn returns, exactly as groupBy did, so the results are
  // unchanged: for each key fn produces, the elements that produce it, in
  // list order.
  function groupBy<T>(fn: T -> string, list: seq<T>): map<string, seq<T>>
  { List.partition(fn, list) }

  // `useWith(map, pickAll, identity)`: `map(pickAll(names), list)`.
  function project<V>(names: seq<string>, list: seq<map<string, V>>): seq<map<string, Option<V>>>
  { List.mapSeq((obj: map<string, V>) => Object.pickAll(names, obj), list) }
}
