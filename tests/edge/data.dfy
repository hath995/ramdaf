// Edge cases for Sort and Data, checked against ramda.js v0.1.1 under node;
// the last methods pin documented deviations (README "Deviations").

module RamdafTests.Edge.Data {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Sort
  import opened Ramdaf.Data

  method {:test} ComparatorSigns() {
    var c := comparator((a: int, b: int) => a < b);
    expect c(1, 2) == -1;
    expect c(2, 1) == 1;
    expect c(1, 1) == 0;
    expect sort(c, [5, 5, 1]) == [1, 5, 5];
  }

  // sort and sortBy are stable (equal keys keep their input order).
  method {:test} SortIsStable() {
    var empty: seq<int> := [];
    expect sort((a: int, b: int) => a - b, empty) == [];
    expect sort((a: string, b: string) => |a| - |b|,
                ["bb", "a", "cc", "d", "eee", "f", "gg", "h", "ii", "j", "kkk", "l"]) ==
      ["a", "d", "f", "h", "j", "l", "bb", "cc", "gg", "ii", "eee", "kkk"];
  }

  method {:test} SortByIsStable() {
    expect sortBy((x: int) => x % 2, [3, 2, 1, 4]) == [2, 4, 3, 1];
    expect sortBy((x: int) => x % 2, [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]) ==
      [10, 8, 6, 4, 2, 0, 11, 9, 7, 5, 3, 1];
    expect sortBy((x: int) => -x, [1, 2, 3]) == [3, 2, 1];
    expect sortBy((s: string) => |s|, ["ccc", "a", "bb"]) == ["a", "bb", "ccc"];
    // {k, i} records, sorted by k: the i's come out 1, 3, 0, 2
    expect sortBy((r: (int, int)) => r.0, [(2, 0), (1, 1), (2, 2), (1, 3)]) == [(1, 1), (1, 3), (2, 0), (2, 2)];
  }

  // union/difference/intersection keep the last occurrence (uniq);
  // intersection takes its elements, and their order, from the second list.
  method {:test} SetOperationsKeepLastOccurrences() {
    var empty: seq<int> := [];
    expect union([1, 2, 3], [1]) == [2, 3, 1];
    expect union(empty, empty) == [];
    expect difference([1, 2, 1, 3], [3]) == [2, 1];
    expect difference([1, 1, 2], empty) == [1, 2];
    expect intersection([1, 2, 1, 3], [1, 2]) == [1, 2];
    expect intersection([2, 1, 2], [2, 1]) == [2, 1];
    expect intersection([1, 2, 3, 4], [4, 3, 2]) == [4, 3, 2];
    expect intersection([1, 2, 1, 3], [3, 1, 1]) == [3, 1];
    expect intersection([1, 2], [3, 1, 2, 1]) == [2, 1];
  }

  function mod3(a: int, b: int): bool { a % 3 == b % 3 }
  function par(a: int, b: int): bool { a % 2 == b % 2 }

  // The *With functions keep the last representative too (uniqWith scans
  // from the right), and call pred(earlier, later).
  method {:test} WithFunctionsKeepLastRepresentatives() {
    var empty: seq<int> := [];
    expect unionWith(mod3, [1, 2], [4]) == [2, 4];
    expect unionWith(mod3, [1, 2], [4, 5, 6]) == [4, 5, 6];
    expect unionWith(mod3, [1, 2, 3, 4], empty) == [2, 3, 4];
    expect unionWith((a: int, b: int) => a < b, [3, 1, 2], empty) == [3, 2];
    expect differenceWith(par, [1, 2, 3], [4]) == [3];
    expect differenceWith((a: int, b: int) => a == b, [1, 2, 1], [3]) == [2, 1];
    expect intersectionWith(par, [1, 2, 3], [4, 5]) == [2, 3];
    expect intersectionWith((a: int, b: int) => a == b, [2, 1, 2], [2]) == [2];
  }

  function parity(x: int): string { if x % 2 == 0 then "even" else "odd" }

  method {:test} GroupByAndCountByEdges() {
    var empty: seq<int> := [];
    expect groupBy(parity, [1, 2, 3, 4, 5]) == map["odd" := [1, 3, 5], "even" := [2, 4]];
    expect groupBy(parity, empty) == map[];
    expect countBy(parity, [1, 2, 3, 4]) == map["odd" := 2, "even" := 2];
    expect countBy(parity, empty) == map[];
  }

  method {:test} ProjectMissingIsUndefined() {
    expect project(["a", "z"], [map["a" := 1, "b" := 2]]) == [map["a" := Some(1), "z" := None]];
  }

  // ---- documented deviations (not node behaviour) ----

  // node: [3, 2, 1] (V8's order for a comparator that always says "less");
  // the postconditions leave inconsistent comparators open, and the stable
  // insertion sort keeps the input order.
  method {:test} DeviationSortWithAnInconsistentComparator() {
    expect sort((a: int, b: int) => -1, [1, 2, 3]) == [1, 2, 3];
  }

  // JS `===` compares the objects by reference, so none of these are shared
  // (node: 8, 0, 4); Dafny `==` compares their contents.
  method {:test} DeviationStructuralEquality() {
    var ro := [map["a" := 1], map["a" := 2], map["a" := 3], map["a" := 4]];
    var so := [map["a" := 3], map["a" := 4], map["a" := 5], map["a" := 6]];
    expect |union(ro, so)| == 6;
    expect |intersection(ro, so)| == 2;
    expect |difference(ro, so)| == 2;
  }
}
