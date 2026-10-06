// Edge cases Ramda v0.2.4's own suite does not cover, each checked against
// ramda.js v0.2.4 under node (the expected values are node's output). The
// last methods pin the documented deviations (README "Deviations").

module RamdafTests.Edge.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List
  import opened Support

  method {:test} CoreEdges() {
    var empty: seq<int> := [];
    expect tail([1]) == [];
    expect tail(empty) == [];
    expect tail([1, 2]) == [2];
    expect head([5]) == 5;
    expect first([1, 2, 3]) == 1;
    expect last([1, 2, 3]) == 3;
    expect last([5]) == 5;
    expect isEmpty([0]) == false;
    expect concat(empty, [1]) == [1];
    expect concat([1], empty) == [1];
    expect concat([1, 2], [3]) == [1, 2, 3];
    expect append(1, empty) == [1];
    expect prepend(1, empty) == [1];
    expect size(empty) == 0;
    expect clone([1, 2]) == [1, 2];
    expect identity(3) == 3;
    expect repeatN(7, 0) == [];
    expect repeatN("a", 2) == ["a", "a"];
    expect times((i: nat) => i * i, 4) == [0, 1, 4, 9];
    expect times((i: nat) => i, 0) == [];
  }

  // foldr runs from the right with the accumulator first (since v0.1.1).
  method {:test} FoldrRunsFromTheRightAccumulatorFirst() {
    var empty: seq<int> := [];
    expect foldr((acc: seq<int>, x: int) => [x] + acc, empty, [1, 2]) == [1, 2];
    expect foldr((acc: string, a: string) => acc + a, "", ["x", "y", "z"]) == "zyx";
    expect foldr((acc: int, a: int) => acc - a, 0, [1, 2, 3, 4]) == -10;
  }

  // The idx folds pass (acc, element, index, list).
  method {:test} IdxFoldsPassTheIndexAndList() {
    var empty: seq<string> := [];
    var f := (acc: string, x: string, i: nat, l: seq<string>) => acc + x + NumStr(i) + NumStr(|l|);
    expect foldlIdx(f, "", ["a", "b"]) == "a02b12";
    expect foldrIdx(f, "", ["a", "b"]) == "b12a02";
    expect foldlIdx(f, "5", empty) == "5";
    expect reduceIdx((acc: int, x: int, i: nat, l: seq<int>) => acc + x * i, 0, [1, 2, 3]) == 8;
    var none: seq<nat> := [];
    expect reduceRightIdx((acc: seq<nat>, x: int, i: nat, l: seq<int>) => acc + [i], none, [9, 9, 9]) == [2, 1, 0];
  }

  method {:test} IdxMapFilterRejectEdges() {
    var empty: seq<int> := [];
    expect mapIdx((x: int, i: nat, l: seq<int>) => x + i, empty) == [];
    expect mapIdx((x: int, i: nat, l: seq<int>) => |l| - i, [5, 5, 5]) == [3, 2, 1];
    expect filterIdx((x: int, i: nat, l: seq<int>) => i == 1, [7, 7, 7]) == [7];
    expect filterIdx((x: int, i: nat, l: seq<int>) => false, [1, 2]) == [];
    expect filterIdx((x: int, i: nat, l: seq<int>) => i < |l|, [1, 2]) == [1, 2];
    expect rejectIdx((x: int, i: nat, l: seq<int>) => i == 1, [7, 7, 7]) == [7, 7];
    expect rejectIdx((x: int, i: nat, l: seq<int>) => true, empty) == [];
  }

  // findLast/findLastIndex never test index 0 (the `while (--idx)` loop);
  // since v0.2.0 findIndex and findLastIndex return -1 on a miss.
  method {:test} FindFamilyEdges() {
    var empty: seq<int> := [];
    expect findIndex((x: int) => true, empty) == -1;
    expect findIndex((x: int) => x > 1, [1, 2, 3]) == 1;
    expect findIndex((x: int) => x > 9, [1, 2, 3]) == -1;
    expect findLastIndex((x: int) => x == 1, [1, 2, 3]) == -1;
    expect findLastIndex((x: int) => x > 1, [1, 2, 3]) == 2;
    expect findLastIndex((x: int) => true, [5]) == -1;
    expect findLast((x: int) => x == 1, [1, 2, 3]) == None;
    expect findLast((x: int) => x < 3, [1, 2, 3]) == Some(2);
    expect findLast((x: int) => true, [5]) == None;
    expect findLast((x: int) => x % 2 == 0, [2, 4, 1]) == Some(4);
  }

  // Array.prototype.slice: negative indices count from the end, both are
  // clamped, and an empty range gives [].
  method {:test} SliceClampsLikeJs() {
    var l := [1, 2, 3, 4, 5];
    expect slice(1, 3, l) == [2, 3];
    expect slice(-2, 100, l) == [4, 5];
    expect slice(3, 1, l) == [];
    expect slice(-100, 2, l) == [1, 2];
    expect slice(2, -1, l) == [3, 4];
    expect slice(0, 0, l) == [];
    expect slice(5, 5, l) == [];
    expect slice(-2, -1, l) == [4];
    expect slice(10, 20, l) == [];
    expect sliceFrom(2, [1, 2, 3]) == [3];
    expect sliceFrom(-2, [1, 2, 3]) == [2, 3];
  }

  function parity(x: int): string { if x % 2 == 0 then "even" else "odd" }

  // partition groups by whatever key the function returns.
  method {:test} PartitionEdges() {
    var empty: seq<int> := [];
    expect partition(parity, [1, 2, 3, 4, 5]) == map["odd" := [1, 3, 5], "even" := [2, 4]];
    expect partition((x: int) => "k", empty) == map[];
    // `String(x > 2)`: a predicate's results as keys
    expect partition((x: int) => if x > 2 then "true" else "false", [1, 3, 2, 4]) == map["false" := [1, 2], "true" := [3, 4]];
    expect partition((s: string) => s, ["b", "a", "b"]) == map["b" := ["b", "b"], "a" := ["a"]];
  }

  method {:test} MapObjEdges() {
    var none: map<string, int> := map[];
    expect mapObj((v: int) => v + 1, none) == map[];
    expect mapObj((v: int) => v * 2, map["a" := 1]) == map["a" := 2];
    expect mapObjIdx((v: int, k: string, o: map<string, int>) => k + NumStr(v), map["a" := 1, "b" := 2]) ==
      map["a" := "a1", "b" := "b2"];
    expect mapObjIdx((v: int, k: string, o: map<string, int>) => |o| + v, map["a" := 1, "b" := 2]) ==
      map["a" := 3, "b" := 4];
    expect mapObjIdx((v: int, k: string, o: map<string, int>) => v, none) == map[];
  }

  method {:test} ContainsWithEdges() {
    var empty: seq<int> := [];
    expect containsWith((a: int, b: int) => a == b + 1, 3, [1, 2]) == true;
    expect containsWith((a: int, b: int) => a == b + 1, 5, [1, 2]) == false;
    expect containsWith((a: int, b: int) => true, 1, empty) == false;
    expect containsWith((a: int, b: int) => a % 10 == b % 10, 12, [2, 3]) == true;
  }

  // isSet(list) is `uniq(list).length === list.length`.
  method {:test} IsSetEdges() {
    var empty: seq<int> := [];
    expect isSet(empty) == true;
    expect isSet([1, 2, 1]) == false;
    expect isSet(["a", "b"]) == true;
    expect isSet([3, 3]) == false;
    var lists := [[1, 2, 1, 3, 2], [4, 5], [6, 6, 6], empty];
    for i := 0 to |lists| {
      expect isSet(lists[i]) == (|uniq(lists[i])| == |lists[i]|);
    }
  }

  method {:test} FoldlIsLeftAssociative() {
    expect foldl((acc: int, x: int) => acc - x, 0, [1, 2, 3]) == -6;
    expect foldl((acc: string, x: string) => acc + x, "", ["a", "b", "c"]) == "abc";
  }

  // Since v0.2.4 uniq keeps the first occurrence of each element (it kept
  // the last).
  method {:test} UniqKeepsFirstOccurrences() {
    expect uniq([1, 2, 1, 3, 2]) == [1, 2, 3];
    expect uniq([3, 3, 3]) == [3];
  }

  // Since v0.2.4 uniqWith keeps the first representative and drops item when
  // pred(item, r) holds for a kept r.
  method {:test} UniqWithKeepsFirstRepresentatives() {
    var empty: seq<int> := [];
    expect uniqWith((a: int, b: int) => a % 3 == b % 3, [1, 2, 3, 4]) == [1, 2, 3];
    expect uniqWith((a: int, b: int) => a < b, [1, 2, 3]) == [1, 2, 3];
    expect uniqWith((a: int, b: int) => a < b, [3, 2, 1]) == [3];
    expect uniqWith((a: int, b: int) => a == b, [1, 2, 1]) == [1, 2];
    expect uniqWith((a: int, b: int) => a == b, empty) == [];
  }

  // Since v0.1.5 take clamps n to the list's length; since v0.2.0 skip
  // throws for n > |list| (outside the domain).
  method {:test} TakeSkipEdges() {
    var empty: seq<int> := [];
    expect take(0, [1, 2]) == [];
    expect take(2, [1, 2]) == [1, 2];
    expect take(5, [1, 2]) == [1, 2];
    expect take(3, empty) == [];
    expect take(2, [1, 2, 3]) == [1, 2];
    expect skip(0, [1, 2]) == [1, 2];
    expect skip(2, [1, 2]) == [];
    expect drop(1, [1, 2]) == [2];
  }

  // Since v0.2.0 zip and zipWith stop at the shorter list.
  method {:test} ZipEdges() {
    var empty: seq<int> := [];
    expect zip([1], [3, 4]) == [(1, 3)];
    expect zip(empty, [1]) == [];
    expect zipWith((a: int, b: int) => a + b, [1, 2], [10, 20, 30]) == [11, 22];
    expect zip([1, 2, 3], [4]) == [(1, 4)];
    expect zipWith((a: int, b: int) => a + b, [1, 2], [10]) == [11];
  }

  // remove, insert and insert.all are built on `_slice`; since v0.2.4 a cut
  // at 0 is empty (until v0.2.3 it copied the whole list).
  method {:test} RemoveUsesRamdasSlice() {
    var l := [1, 2, 3, 4, 5];
    var empty: seq<int> := [];
    expect remove(1, 2, l) == [1, 4, 5];
    expect remove(0, 2, l) == [3, 4, 5];
    expect remove(0, 0, [1, 2, 3]) == [1, 2, 3];
    expect remove(0, 5, l) == [];
    expect remove(3, 10, [1, 2, 3]) == [1, 2, 3];
    expect remove(5, 1, [1, 2, 3]) == [1, 2, 3];
    expect remove(1, -1, l) == [1, 1, 2, 3, 4, 5];
    expect remove(3, -1, l) == [1, 2, 3, 3, 4, 5];
    expect remove(2, -2, l) == [1, 2, 1, 2, 3, 4, 5];
    expect remove(1, 0, l) == l;
    expect remove(0, 1, empty) == [];
    expect remove(2, 0, empty) == [];
  }

  method {:test} InsertUsesRamdasSlice() {
    var empty: seq<int> := [];
    expect insert(1, 9, [1, 2, 3]) == [1, 9, 2, 3];
    expect insert(0, 9, [1, 2, 3]) == [9, 1, 2, 3];
    expect insert(2, 9, [1, 2, 3]) == [1, 2, 9, 3];
    expect insert(3, 9, [1, 2, 3]) == [1, 2, 3, 9];
    expect insert(10, 9, [1, 2, 3]) == [1, 2, 3, 9];
    expect insert(-1, 9, [1, 2, 3]) == [1, 2, 3, 9];
    expect insert(0, 9, empty) == [9];
    expect insert(5, 9, empty) == [9];
    expect insertAll(1, [7, 8], [1, 2, 3]) == [1, 7, 8, 2, 3];
    expect insertAll(0, [7, 8], [1, 2, 3]) == [7, 8, 1, 2, 3];
    expect insertAll(-1, [7, 8], [1, 2, 3]) == [1, 2, 3, 7, 8];
    expect insertAll(5, [7, 8], [1, 2, 3]) == [1, 2, 3, 7, 8];
    expect insertAll(0, empty, [1, 2, 3]) == [1, 2, 3];
    expect insertAll(2, empty, [1, 2, 3]) == [1, 2, 3];
    expect insertAll(0, [7], empty) == [7];
  }

  // indexOf.from/lastIndexOf.from (v0.2.2): a negative fromIdx counts from
  // the end; lastIndexOf.from searches at and below fromIdx.
  method {:test} IndexOfFromEdges() {
    var empty: seq<int> := [];
    expect indexOfFrom(2, 1, [2, 1, 2, 3]) == 2;
    expect indexOfFrom(2, -2, [2, 1, 2, 3]) == 2;
    expect indexOfFrom(2, -10, [2, 1, 2]) == 0;
    expect indexOfFrom(2, 10, [2]) == -1;
    expect indexOfFrom(2, 0, empty) == -1;
    expect indexOfFrom(3, 3, [1, 2, 3]) == -1;
    expect lastIndexOfFrom(2, 1, [2, 1, 2, 3]) == 0;
    expect lastIndexOfFrom(2, -1, [2, 1, 2]) == 2;
    expect lastIndexOfFrom(2, -10, [2, 1, 2]) == -1;
    expect lastIndexOfFrom(2, 10, [2, 1, 2]) == 2;
    expect lastIndexOfFrom(2, 0, empty) == -1;
    expect lastIndexOfFrom(1, -3, [1, 2, 3]) == 0;
  }

  method {:test} NthEdges() {
    expect nth(-1, [1, 2]) == None;
    expect nth(9, [1, 2]) == None;
    expect nth(0, [1, 2]) == Some(1);
  }

  method {:test} JoinEdges() {
    var empty: seq<string> := [];
    expect join(",", empty) == "";
    expect join("-", ["a"]) == "a";
    expect join("", ["a", "b"]) == "ab";
  }

  method {:test} RangeEdges() {
    expect range(-2, 2) == [-2, -1, 0, 1];
    expect range(3, 3) == [];
  }

  method {:test} FindTakeWhileSkipUntilEdges() {
    var empty: seq<int> := [];
    expect find((x: int) => x > 9, [1, 2]) == None;
    expect find((x: int) => x > 1, [1, 2, 3]) == Some(2);
    expect takeWhile((x: int) => x < 3, [1, 2, 3, 1]) == [1, 2];
    expect takeWhile((x: int) => x > 0, empty) == [];
    expect takeWhile((x: int) => x < 2, [1, 2, 3]) == [1];
    expect takeWhile((x: int) => x < 9, [1, 2]) == [1, 2];
    // v0.2.4 (it was the whole list from v0.2.0 to v0.2.3)
    expect takeWhile((x: int) => x > 5, [1, 2, 3]) == [];
    expect skipUntil((x: int) => x > 2, [1, 2, 3, 1]) == [3, 1];
    expect skipUntil((x: int) => x > 0, empty) == [];
  }

  method {:test} FlattenEdges() {
    var empty: seq<Tree<int>> := [];
    expect flatten(empty) == [];
    expect flatten([Node(empty)]) == [];
    expect flatten([Leaf(1), Node(empty), Node([Node([Leaf(2)])])]) == [1, 2];
  }

  // A falsy result (or an empty pair) stops the unfold.
  method {:test} UnfoldrStopsAtNone() {
    expect unfoldr((n: int) => if n < 3 then Some((n, n + 1)) else None, 0, 100) == [0, 1, 2];
  }

  method {:test} PluckMissingIsUndefined() {
    expect pluck("nope", [map["a" := 1]]) == [None];
    expect pluck("a", [map["a" := 1], map["b" := 2]]) == [Some(1), None];
  }

  method {:test} MiscListEdges() {
    var empty: seq<int> := [];
    expect reverse([1]) == [1];
    expect indexOf(2, [1, 2, 3, 2]) == 1;
    expect lastIndexOf(2, [1, 2, 3, 2]) == 3;
    expect xprod(empty, [1]) == [];
    expect xprod([1], empty) == [];
    expect all((x: int) => x > 0, empty) == true;
    expect any((x: int) => x > 0, empty) == false;
    expect reject((x: int) => x > 1, [1, 2, 3]) == [1];
    expect contains(3, [1, 2]) == false;
    expect mapSeq((x: int) => x * x, empty) == [];
  }

  // ---- documented deviations (not node behaviour) ----

  // JS unfoldr would loop forever here; the fuel bound stops it.
  method {:test} DeviationUnfoldrStopsAtFuel() {
    expect unfoldr((n: int) => Some((n, n + 1)), 0, 3) == [0, 1, 2];
  }
}
